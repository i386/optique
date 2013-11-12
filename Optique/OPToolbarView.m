//
//  OPToolvarView.m
//  Optique
//
//  Created by James Dumay on 12/11/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPToolbarView.h"
#import "NSColor+Optique.h"
#import "NSWindow+FullScreen.h"

@implementation OPToolbarView


- (void)drawRect:(NSRect)dirtyRect
{
	if (self.window.isFullscreen)
    {
        [[NSColor whiteColor] set];
        NSRectFill(dirtyRect);
    }
    else
    {
        [super drawRect:dirtyRect];
    }
}

@end
