//
//  OPDebugView.m
//  Optique
//
//  Created by James Dumay on 8/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#if DEBUG

#import "OPDebugView.h"

@implementation OPDebugView

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    [[NSColor redColor] set];
    NSRectFill(dirtyRect);
}

@end

#endif