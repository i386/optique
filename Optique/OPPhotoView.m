//
//  OPPhotoView.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoView.h"
#import "OPPhotoViewController.h"
#import "NSView+OptiqueBackground.h"
#import "NSPasteboard+XPPhoto.h"
#import "NSImage+Transform.h"
#import "NSImage+CGImage.h"
#import "OPImageCache.h"

@implementation OPPhotoView

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawDarkBackground];
}

- (void)keyDown:(NSEvent *)event
{
    NSString *characters = [event characters];
    
    unichar character = [characters characterAtIndex: 0];
    
    if (character == NSRightArrowFunctionKey)
    {
        [_controller nextPhoto];
    }
    else if (character == NSLeftArrowFunctionKey)
    {
        [_controller previousPhoto];
    }
    else if (event.keyCode == 33)
    {
        [_controller backToPhotoCollection];
    }
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)rotateLeft:(id)sender
{
    if ([_controller.collection collectionType] != kPhotoCollectionLocal)
    {
        NSLog(@"Collection type is not local, image cannot be rotated");
        return;
    }
    
    CGImageSourceRef srcRef = CGImageSourceCreateWithURL((__bridge CFURLRef)_controller.visiblePhoto.url, NULL);
    CFStringRef srcRefType = CGImageSourceGetType(srcRef);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(srcRef, 0, nil);
    
    CGImageRef rotatedImageRef = [self CGImageRotatedByAngle:imageRef
                                                    angle:90];
    
    CGImageRelease(imageRef);
    CFRelease(srcRef);
    
    CGImageDestinationRef destRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)_controller.visiblePhoto.url, srcRefType, 1, NULL);
    CGImageDestinationAddImage(destRef, rotatedImageRef, NULL);
    
    NSDictionary *props = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:1.0], kCGImageDestinationLossyCompressionQuality,
                            nil];
    
    //Note that setting kCGImagePropertyOrientation didn't work here for me
    CGImageDestinationSetProperties(destRef, (__bridge CFDictionaryRef) props);
    
    CGImageDestinationFinalize(destRef);
    CFRelease(destRef);
    CGImageRelease(rotatedImageRef);
    CFRelease(srcRefType);
    
    [[OPImageCache sharedPreviewCache] invalidateImageForPath:_controller.visiblePhoto.url];
    
    //Reload image
    [_controller.visiblePhoto scaleImageToFitSize:self.window.frame.size withCompletionBlock:^(NSImage *image) {
        _controller.currentPhotoController.imageView.image = image;
        [_controller.currentPhotoController.imageView setNeedsDisplay:YES];
    }];
}

-(void)copy:(id)sender
{
    NSURL *url = _controller.visiblePhoto.url;
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:@[url, image]];
}

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

//Thanks https://github.com/mjvotaw/iOSImageHelper/blob/master/ImageHelper.m
- (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle
{
    CGFloat angleInRadians = DegreesToRadians(angle);
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGRect imgRect = CGRectMake(0, 0, width, height);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
    CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmContext = CGBitmapContextCreate(NULL,
                                                   rotatedRect.size.width,
                                                   rotatedRect.size.height,
                                                   8,
                                                   0,
                                                   colorSpace,
                                                   kCGImageAlphaPremultipliedFirst);
    CGContextSetAllowsAntialiasing(bmContext, YES);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    CGColorSpaceRelease(colorSpace);
    CGContextTranslateCTM(bmContext,
                          +(rotatedRect.size.width/2),
                          +(rotatedRect.size.height/2));
    CGContextRotateCTM(bmContext, angleInRadians);
    CGContextDrawImage(bmContext, CGRectMake(-width/2, -height/2, width, height),
                       imgRef);
    
    CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
    CFRelease(bmContext);
    
    return rotatedImage;
}

@end
