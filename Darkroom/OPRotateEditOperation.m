//
//  OPRotateEditOperation.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPRotateEditOperation.h"
#import "CALayer+Rotate.h"

@implementation OPRotateEditOperation

-(void)performPreviewOperation:(CALayer *)layer
{
    [layer rotateByDegrees:90];
    [layer setBounds:layer.superlayer.bounds];
    [layer setFrame:layer.superlayer.frame];
}

-(void)performWithItem:(id<XPItem>)item
{
    //Load original with metadata
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCGImageSourceShouldCache, kCFBooleanFalse, nil];
    CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)(item.url), (__bridge CFDictionaryRef)(options));
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, nil);
    CFMutableDictionaryRef newImageProperties = CFDictionaryCreateMutableCopy(nil, 0, properties);
    
    CGImageRef theImage = CGImageSourceCreateImageAtIndex(sourceRef, 0, nil);

    CGFloat pixelsHeight = CGImageGetHeight(theImage);
    CGFloat pixelsWidth = CGImageGetWidth(theImage);
    
    //Flip dimensions
    CGRect dimensions = CGRectMake(0, 0, pixelsWidth, pixelsHeight);
    
    //
    CGContextRef context = CreateBitmapContext(theImage, CGSizeMake(pixelsHeight, pixelsWidth));
    
    CGAffineTransform  tran = CGAffineTransformIdentity;
    tran = CGAffineTransformMakeTranslation(0.0, pixelsWidth);
    tran = CGAffineTransformRotate(tran, -(90 * M_PI / 180));
    CGContextScaleCTM(context, -1.0, 1.0);
    CGContextTranslateCTM(context, -pixelsHeight, 0.0);
    CGContextConcatCTM(context, tran);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, pixelsHeight);
    CGContextConcatCTM(context, flipVertical);
    
    CGContextDrawImage(context, dimensions, theImage);
	
    CGImageRef cgImageRotated = CGBitmapContextCreateImage(context);
    
    //Save, with original metadata
    CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)(item.url), CGImageSourceGetType(sourceRef), 0, nil);
    CGImageDestinationAddImage(destinationRef, cgImageRotated, newImageProperties);
    CGImageDestinationFinalize(destinationRef);
    
    //Cleanup
    CFRelease(destinationRef);
    CFRelease(sourceRef);
//    CGImageRelease(theImage);
//    CGImageRelease(cgImageRotated);
//    CGContextRelease(cgContextRef);
}

CGContextRef CreateBitmapContext (CGImageRef inImage, CGSize size)
{
    CGFloat bitmapBytesPerRow = (size.width * 4) * size.height;
    
    // Preserve color space
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(inImage);
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    //Create a new context with the same format of the original
    CGContextRef context = CGBitmapContextCreate (NULL,
                                     size.width,
                                     size.height,
                                     CGImageGetBitsPerComponent(inImage),
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     CGImageGetAlphaInfo(inImage));
    if (context == NULL)
    {
        fprintf (stderr, "Context not created!\n");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

@end
