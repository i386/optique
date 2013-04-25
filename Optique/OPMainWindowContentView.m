//
//  OPMainWindow.m
//  Optique
//
//  Created by James Dumay on 25/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPMainWindowContentView.h"

@interface OPMainWindowContentView() {
    NSTrackingArea *_mouseTrackingArea;
}
@end

@implementation OPMainWindowContentView


- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    
    if (_mouseTrackingArea)
    {
        [self removeTrackingArea:_mouseTrackingArea];
    }
    
    NSRect trackingRect = self.bounds;
    trackingRect.size.width = 70;
    
    _mouseTrackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect
                                                          options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                            owner:self
                                                         userInfo:nil];
    
    [self addTrackingArea:_mouseTrackingArea];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    if (_allowedToShowNavButton)
    {
        NSMutableArray *subviews = [NSMutableArray arrayWithArray:[self subviews]];
        [subviews removeObject:_navigationButton];
        [subviews addObject:_navigationButton];
        [self setSubviews:subviews];
        [_navigationButton setHidden:NO];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [_navigationButton setHidden:YES];
}


@end
