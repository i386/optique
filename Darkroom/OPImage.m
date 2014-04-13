//
//  OPImage.m
//  Optique
//
//  Created by James Dumay on 13/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OPImage.h"
#import "OPImageOrientation.h"
#import "OPGraphics.h"

@implementation OPImage

-(id)initWithCGImageRef:(CGImageRef)imageRef properties:(NSDictionary *)properties
{
    self = [super init];
    if (self)
    {
        imageRef = [self ensureCorrectOrientation:imageRef properties:properties];
        _image = [[CIImage alloc] initWithCGImage:imageRef];
        _properties = [NSMutableDictionary dictionaryWithDictionary:properties];
    }
    return self;
}

-(id)initWithCIImage:(CIImage *)image properties:(NSDictionary *)properties
{
    self = [super init];
    if (self)
    {
        _image = image;
        _properties = [NSMutableDictionary dictionaryWithDictionary:properties];
    }
    return self;
}

-(CGImageRef)ensureCorrectOrientation:(CGImageRef)imageRef properties:(NSDictionary*)properties
{
    OPImageOrientation orientation = OPImageOrientationGetFromProperties((__bridge CFDictionaryRef)(properties));
	// If the orientation isn't 1 (the default orientation) then we'll create a new image at orientation 1
	if(orientation != 1)
	{
		CGContextRef context;
		size_t width = CGImageGetWidth(imageRef), height = CGImageGetHeight(imageRef);
		if(orientation <= OPImageOrientationRight)
		{
			// Orientations 1-4 are rotated 0 or 180 degrees, so they retain the width/height of the image
            context = [OPGraphics createBitmapContext:imageRef size:CGSizeMake(width, height)];
		}
		else
		{
			// Orientations 5-8 are rotated ±90 degrees, so they swap width & height.
            context = [OPGraphics createBitmapContext:imageRef size:CGSizeMake(height, width)];
		}
        
		switch(orientation)
		{
            case OPImageOrientationUp:
                return imageRef;
                break;
                
			case OPImageOrientationDown:
				// 2 = 0th row is at the top, and 0th column is on the right - Flip Horizontal
				CGContextConcatCTM(context, CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, width, 0.0));
				break;
				
			case OPImageOrientationLeft:
				// 3 = 0th row is at the bottom, and 0th column is on the right - Rotate 180 degrees
				CGContextConcatCTM(context, CGAffineTransformMake(-1.0, 0.0, 0.0, -1.0, width, height));
				break;
				
			case OPImageOrientationRight:
				// 4 = 0th row is at the bottom, and 0th column is on the left - Flip Vertical
				CGContextConcatCTM(context, CGAffineTransformMake(1.0, 0.0, 0, -1.0, 0.0, height));
				break;
				
			case OPImageOrientationUpMirrored:
				// 5 = 0th row is on the left, and 0th column is the top - Rotate -90 degrees and Flip Vertical
				CGContextConcatCTM(context, CGAffineTransformMake(0.0, -1.0, -1.0, 0.0, height, width));
				break;
				
			case OPImageOrientationDownMirrored:
				// 6 = 0th row is on the right, and 0th column is the top - Rotate 90 degrees
				CGContextConcatCTM(context, CGAffineTransformMake(0.0, -1.0, 1.0, 0.0, 0.0, width));
				break;
				
			case OPImageOrientationLeftMirrored:
				// 7 = 0th row is on the right, and 0th column is the bottom - Rotate 90 degrees and Flip Vertical
				CGContextConcatCTM(context, CGAffineTransformMake(0.0, 1.0, 1.0, 0.0, 0.0, 0.0));
				break;
				
			case OPImageOrientationRightMirrored:
				// 8 = 0th row is on the left, and 0th column is the bottom - Rotate -90 degrees
				CGContextConcatCTM(context, CGAffineTransformMake(0.0, 1.0, -1.0, 0.0, height, 0.0));
				break;
		}
		// Finally draw the image and replace the one in the ImageInfo struct.
		CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), imageRef);
		CFRelease(imageRef);
		imageRef = CGBitmapContextCreateImage(context);
		CFRelease(context);
	}
    return imageRef;
}

@end
