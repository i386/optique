//
//  OPScrollView.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPScrollView.h"
#import "NSView+OptiqueBackground.h"

@implementation OPScrollView

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        [self setDrawsBackground:NO];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawTransparentBackground];
}

@end
