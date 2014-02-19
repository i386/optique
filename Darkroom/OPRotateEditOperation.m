//
//  OPRotateEditOperation.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPRotateEditOperation.h"
#import "CALayer+Rotate.h"
#import "NSURL+Renamer.h"

@interface OPRotateEditOperation ()
@end

@implementation OPRotateEditOperation

-(void)performPreviewOperation:(CALayer *)layer
{
    [layer rotateByDegrees:-90];
    [layer setBounds:layer.superlayer.bounds];
    [layer setFrame:layer.superlayer.frame];
}

-(void)performWithItem:(id<XPItem>)item
{
    //Load original with metadata
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCGImageSourceShouldCache, kCFBooleanFalse, nil];
    CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)(item.url), (__bridge CFDictionaryRef)(options));
    if (sourceRef)
    {
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, nil);
        CFMutableDictionaryRef newImageProperties = CFDictionaryCreateMutableCopy(nil, 0, properties);
        
        CGImageRef theImage = CGImageSourceCreateImageAtIndex(sourceRef, 0, nil);
        if (theImage)
        {
            CGFloat pixelsHeight = CGImageGetHeight(theImage);
            CGFloat pixelsWidth = CGImageGetWidth(theImage);
            
            //Flip dimensions
            CGRect dimensions = CGRectMake(0, 0, pixelsWidth, pixelsHeight);
            
            //Create bitmap context w/ the dimensions of the rotated image
            CGContextRef context = CreateARGBBitmapContext(theImage, CGSizeMake(pixelsHeight, pixelsWidth));
            if (context)
            {
                //Rotate the image
                CGAffineTransform tran = CGAffineTransformIdentity;
                tran = CGAffineTransformMakeTranslation(0.0, pixelsWidth);
                tran = CGAffineTransformRotate(tran, -(90 * M_PI / 180));
                CGContextScaleCTM(context, -1.0, 1.0);
                CGContextTranslateCTM(context, -pixelsHeight, 0.0);
                CGContextConcatCTM(context, tran);
                CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, pixelsHeight);
                CGContextConcatCTM(context, flipVertical);
                
                //Draw the rotated image
                CGContextDrawImage(context, dimensions, theImage);
                
                //Get rotated image from context
                CGImageRef rotatedImage = CGBitmapContextCreateImage(context);
                if (rotatedImage)
                {
                    NSURL *url = item.url;
                    
                    //Save, with original metadata
                    CFStringRef sourceImageType = CGImageSourceGetType(sourceRef);
                    CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)(url), sourceImageType, 0, nil);
                    if (!destinationRef)
                    {
                        url = [[[item.url URLByDeletingPathExtension] URLByAppendingPathExtension:@"tiff"] URLWithUniqueNameIfExistsAtParent];
                        destinationRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)(url), kUTTypeTIFF, 0, nil);
                    }
                    
                    if (destinationRef)
                    {
                        CGImageDestinationAddImage(destinationRef, rotatedImage, newImageProperties);
                        CGImageDestinationFinalize(destinationRef);
                        CFRelease(destinationRef);
                    }
                    else
                    {
                        NSLog(@"RotateOperation: Could not create image destination for rotated image %@", item.url);
                    }
                    CGImageRelease(rotatedImage);
                }
                else
                {
                    NSLog(@"RotateOperation: Could not create bitmap for rotated image %@", item.url);
                }
            }
            else
            {
                NSLog(@"RotateOperation: Could not create bitmap context %@", item.url);
            }
            
            CGImageRelease(theImage);
        }
        else
        {
            NSLog(@"RotateOperation: Could not create image %@", item.url);
        }
        
        CFRelease(sourceRef);
    }
    else
    {
        NSLog(@"RotateOperation: Could not create image source %@", item.url);
    }
}

CGContextRef CreateARGBBitmapContext (CGImageRef inImage, CGSize size)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (size.width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * size.height);
    
    // Use the generic RGB color space.
    colorSpace = CGImageGetColorSpace(inImage);
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     size.width,
                                     size.height,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
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
