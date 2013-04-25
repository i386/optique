//
//  OPTextLayer.m
//  Optique
//
//  Created by James Dumay on 2/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPTextLayer.h"
#import "NSView+OptiqueBackground.h"

@implementation OPTextLayer

-(void)drawInContext:(CGContextRef)ctx
{
    NSColor *color = [NSColor controlHighlightColor];
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect (ctx, [self bounds]);
    CGContextSetShouldSmoothFonts (ctx, true);
    [super drawInContext:ctx];
}

@end
