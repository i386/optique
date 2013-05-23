//
//  OPNavigationBar.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationTitle.h"
#import "NSWindow+FullScreen.h"

@implementation OPNavigationTitle

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullScreen:) name:NSWindowWillExitFullScreenNotification object:self.window];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterFullScreen:) name:NSWindowDidEnterFullScreenNotification object:self.window];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillExitFullScreenNotification object:self.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEnterFullScreenNotification object:self.window];
}

-(void)willExitFullScreen:(NSNotification*)notification
{
    [_viewLabel.animator setHidden:YES];
}

-(void)didEnterFullScreen:(NSNotification*)notification
{
    [_viewLabel.animator setHidden:NO];
}

-(void)updateTitle:(NSString *)title
{
    [self.window setTitle:title];
    [_viewLabel setStringValue:title];
}

- (IBAction)filterSegmentChanged:(id)sender {
}

@end
