//
//  NSView+OptiqueBackground.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSView+OptiqueBackground.h"
#import "NSColor+Optique.h"

@implementation NSView (OptiqueBackground)

-(void)drawBackground
{
    [[NSColor optiqueBackgroundColor] set];
    NSRectFill(self.bounds);
}

-(void)drawTransparentBackground
{
    [[NSColor clearColor] set];
    NSRectFill(self.bounds);
}

-(void)drawDarkBackground
{
    [[NSColor optiqueDarkBackgroundColor] set];
    NSRectFill(self.bounds);
}

-(void)drawEffectsViewBackground
{
    NSImage *bgImage = [NSImage imageNamed:@"effectsbarbg"];
    
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(context);
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[bgImage TIFFRepresentation], NULL);
    CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    CGContextDrawTiledImage(context, NSMakeRect(0.0f, 0.0f, bgImage.size.width, bgImage.size.height), maskRef);
    CGContextRestoreGState(context);
}

-(void)drawEffectsViewBackgroundSelected
{
    NSImage *bgImage = [NSImage imageNamed:@"effectsbarselectedbg"];
    
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(context);
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[bgImage TIFFRepresentation], NULL);
    CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    CGContextDrawTiledImage(context, NSMakeRect(0.0f, 0.0f, bgImage.size.width, bgImage.size.height), maskRef);
    CGContextRestoreGState(context);
}

@end
