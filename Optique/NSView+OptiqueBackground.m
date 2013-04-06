//
//  NSView+OptiqueBackground.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSView+OptiqueBackground.h"

@implementation NSView (OptiqueBackground)

+ (NSColor*)gradientTopColor
{
    return [NSColor colorWithCalibratedRed:0.76 green:0.76 blue:0.76 alpha:1.00];
}

+ (NSColor*)gradientBottomColor
{
    return [NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:1.00];
}

-(void)drawBackground
{
    [[NSColor windowBackgroundColor] set];
    NSRectFill(self.bounds);
}

-(void)drawTransparentBackground
{
    [[NSColor clearColor] set];
    NSRectFill(self.bounds);
}

-(void)drawWhiteBackground
{
    [[NSColor whiteColor] set];
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
