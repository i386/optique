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
#import "OPGraphics.h"
#import "CIImage+Rotation.h"
#import "CIImage+CGImageRef.h"

@interface OPRotateEditOperation ()
@end

@implementation OPRotateEditOperation

-(OPImage*)perform:(OPImage*)image layer:(CALayer *)layer
{
    CIImage *ciImage = [image.image rotateByDegrees:90];
    CGImageRef imageRef = ciImage.imageRef;
    layer.contents = (__bridge id)(imageRef);
    return [[OPImage alloc] initWithCIImage:ciImage properties:image.properties];
}

@end
