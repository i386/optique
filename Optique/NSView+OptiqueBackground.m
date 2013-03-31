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
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSView gradientBottomColor] endingColor:[NSView gradientTopColor]];
    [gradient drawInRect:self.bounds angle:270];
}

-(void)drawTransparentBackground
{
    [[NSColor clearColor] set];
    NSRectFill(self.bounds);
//    NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver);
}

@end
