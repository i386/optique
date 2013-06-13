//
//  OPWindow.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPWindow.h"
#import "NSWindow+FullScreen.h"
#import "NSColor+Optique.h"

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
    [self setShowsTitle:NO];
    [self setTitleBarHeight:36];
    [self setCenterTrafficLightButtons:YES];
    [self setCenterFullScreenButton:YES];
    
    [self setTitleBarDrawingBlock:^(BOOL drawsAsMainWindow, CGRect drawingRect, CGPathRef clippingPath)
     {
         CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
         
         //Fill title
         CGContextAddPath(context, clippingPath);
         [[NSColor optiqueTitlebarColor] setFill];
         CGContextAddPath(context, clippingPath);
         CGContextDrawPath(context, kCGPathFill);
         
         
         //Draw line at bottom
         CGPoint startPoint = CGPointMake(drawingRect.origin.x, drawingRect.origin.y);
         CGPoint endPoint = CGPointMake(drawingRect.origin.x + drawingRect.size.width - 1, drawingRect.origin.y);
         
         CGContextSaveGState(context);
         CGContextSetLineCap(context, kCGLineCapSquare);
         CGContextSetStrokeColorWithColor(context, [NSColor optiqueTitlebarBorderColor].CGColor);
         CGContextSetLineWidth(context, 1.0);
         CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
         CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
         CGContextStrokePath(context);
         CGContextRestoreGState(context);
     }];
}

@end
