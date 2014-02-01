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

-(void)performOperation:(CGImageRef)image
{
    NSLog(@"Rotate left");
}

@end
