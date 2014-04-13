//
//  CIImage+CGImageRef.m
//  Optique
//
//  Created by James Dumay on 13/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "CIImage+CGImageRef.h"

@implementation CIImage (CGImageRef)

-(CGImageRef)imageRef
{
    CIContext *context = [[NSGraphicsContext currentContext] CIContext];
    return [context createCGImage:self fromRect:[self extent]];
}

@end
