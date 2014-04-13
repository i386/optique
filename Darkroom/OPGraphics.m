//
//  OPGraphics.m
//  Optique
//
//  Created by James Dumay on 13/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPGraphics.h"

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
};

@implementation OPGraphics

+(CGContextRef)createBitmapContext:(CGImageRef)inImage size:(CGSize)size
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
                                                  (CGBitmapInfo)CGImageGetAlphaInfo(inImage));
    if (context == NULL)
    {
        fprintf (stderr, "Context not created!\n");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

@end
