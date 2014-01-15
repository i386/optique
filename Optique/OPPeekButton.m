//
//  OPPeekButton.m
//  Optique
//
//  Created by James Dumay on 4/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPPeekButton.h"

@interface OPPeekButton()

@property (strong) NSTrackingArea *trackingArea;

@end

@implementation OPPeekButton

-(void)mouseEntered:(NSEvent *)theEvent
{
    [self performSelector:@selector(showPopover) withObject:nil afterDelay:0.8];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void)updateTrackingAreas
{
    [super updateTrackingAreas];
    
    if (_trackingArea)
    {
        [self removeTrackingArea:_trackingArea];
    }
    
    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways;
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.frame options:options owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

-(void)showPopover
{
    if (_peek && _historyPeekViewController.view && _historyPeekViewController.showable)
    {
        [_historyPeekViewController.popover showRelativeToRect:self.frame ofView:self preferredEdge:CGRectMaxYEdge];
    }
}

@end
