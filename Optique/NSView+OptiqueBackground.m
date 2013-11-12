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

-(void)drawDarkFullscreenBackground
{
    [[NSColor optiqueDarkFullscreenColor] set];
    NSRectFill(self.bounds);
}

@end
