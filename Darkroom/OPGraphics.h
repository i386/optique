//
//  OPGraphics.h
//  Optique
//
//  Created by James Dumay on 13/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

CGFloat DegreesToRadians(CGFloat degrees);

CGFloat RadiansToDegrees(CGFloat radians);

@interface OPGraphics : NSObject

+(CGContextRef)createBitmapContext:(CGImageRef)inImage size:(CGSize)size;

@end
