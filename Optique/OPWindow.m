//
//  OPWindow.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPWindow.h"

@implementation OPWindow

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self)
    {
        [self setup];
    }
    return self;
}

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen];
    if (self)
    {
        [self setup];
    }
    return self;
}

-(void)setup
{
    [self setHideTitleBarInFullScreen:NO];
    [self setTitleTextColor:[NSColor whiteColor]];
    [self setInactiveTitleTextColor:[NSColor controlColor]];
    [self setShowsTitle:YES];
    [self setTitleBarHeight:36];
    [self setCenterTrafficLightButtons:YES];
    [self setCenterFullScreenButton:YES];
    
    [self setTitleBarDrawingBlock:^(BOOL drawsAsMainWindow, CGRect drawingRect, CGPathRef clippingPath)
    {
        NSImage *bgImage = [NSImage imageNamed:@"toolbarbg"];
        
        CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
        CGContextSaveGState(context);
        
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[bgImage TIFFRepresentation], NULL);
        CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
        
        //Do not clip if full screen
        if (([self styleMask] & NSFullScreenWindowMask) != NSFullScreenWindowMask)
        {
            CGContextClipToMask(context, CGRectMake(0, 0, drawingRect.size.width, drawingRect.size.height), maskRef);
            CGContextAddPath(context, clippingPath);
            CGContextClip(context);
        }
        CGContextDrawTiledImage(context, NSMakeRect(0.0f, 0.0f, bgImage.size.width, bgImage.size.height), maskRef);
        CGContextRestoreGState(context);
    }];
}

@end
