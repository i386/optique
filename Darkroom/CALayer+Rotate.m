//
//  CALayer+Rotate.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "CALayer+Rotate.h"

@implementation CALayer (Rotate)

-(void)rotateByDegrees:(float)degrees
{
    CGFloat radians = [(NSNumber *)[self valueForKeyPath:@"transform.rotation.z"] floatValue];
    [self setTransform:CATransform3DMakeRotation(radians + (degrees * M_PI / 180), 0, 0, 1.0)];
}

@end
