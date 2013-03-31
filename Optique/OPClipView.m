//
//  OPClipView.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPClipView.h"
#import "NSView+OptiqueBackground.h"

@implementation OPClipView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDrawsBackground:NO];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawTransparentBackground];
}

@end
