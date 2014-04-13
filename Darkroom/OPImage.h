//
//  OPImage.h
//  Optique
//
//  Created by James Dumay on 13/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Immutable representation of an image for Darkroom operations
 */
@interface OPImage : NSObject

/**
 The current imageRef
 */
@property (readonly, strong) CIImage* image;

/**
 Image properties that will be written to the destination
 */
@property (readonly, strong) NSMutableDictionary *properties;

-initWithCIImage:(CIImage*)image properties:(NSDictionary*)properties;

-initWithCGImageRef:(CGImageRef)image properties:(NSDictionary*)properties;

@end
