//
//  NSImage+CGImage.m
//  Optique
//
//  Created by James Dumay on 6/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSImage+CGImage.h"

@implementation NSImage (CGImage)

-(CGImageRef)CGImageRef
{
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[self TIFFRepresentation], NULL);
    return CGImageSourceCreateImageAtIndex(source, 0, NULL);
}

@end
