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
    [self setShowsTitle:YES];
    [self setTitleBarHeight:53];
    [self setCenterTrafficLightButtons:NO];
    [self setCenterFullScreenButton:NO];
}

@end
