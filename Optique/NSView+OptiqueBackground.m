//
//  NSView+OptiqueBackground.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSView+OptiqueBackground.h"

@implementation NSView (OptiqueBackground)

-(void)drawBackground
{
    [[NSColor controlHighlightColor] set];
    NSRectFill(self.bounds);
}

-(void)drawTransparentBackground
{
    [[NSColor clearColor] set];
    NSRectFill(self.bounds);
}

-(void)drawDarkBackground
{
    [[NSColor colorWithCalibratedRed:0.17 green:0.17 blue:0.17 alpha:1.00] set];
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
