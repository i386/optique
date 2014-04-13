//
//  CIImage+Rotation.m
//  Optique
//
//  Created by James Dumay on 13/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "CIImage+Rotation.h"

@implementation CIImage (Rotation)

- (CIImage *)rotateByDegrees:(float)degrees
{
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform"];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform rotateByDegrees:degrees];
    [filter setValue:transform forKey:@"inputTransform"];
    [filter setValue:self forKey:@"inputImage"];
    return [filter valueForKey:@"outputImage"];
}

@end
