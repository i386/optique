//
//  OPScrollView.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPScrollView.h"
#import "OPClipView.h"
#import "NSView+OptiqueBackground.h"

@implementation OPScrollView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        OPClipView* newClipView = [[[self class] alloc] initWithFrame:[[self contentView] frame]];
        [newClipView setBackgroundColor:[[self contentView] backgroundColor]];
        [self setContentView:(NSClipView*)newClipView];
        [self setDocumentView:self.documentView];
        [self setDrawsBackground:NO];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawTransparentBackground];
}

@end
