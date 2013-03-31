//
//  OPNavigationBar.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationBar.h"
#import "OPNavigationBarButton.h"
#import "NSWindow+FullScreen.h"

@implementation OPNavigationBar

-(void)awakeFromNib
{
    OPNavigationBarButton *button  = (OPNavigationBarButton*)_backButton;
    [button setTextColor:[NSColor whiteColor]];
}

-(void)hideBackButton:(BOOL)hide
{
    [_backButton setHidden:hide];
}

-(void)backClicked:(id)sender
{
    [_navigationController popToPreviousViewController];
}

-(void)updateTitle:(NSString *)title
{
    if ([self.window isFullscreen])
    {
        [_viewLabel setStringValue:title];
    }
    else
    {
        [_viewLabel setStringValue:[NSString stringWithFormat:@"Optique - %@", title]];
    }
}

@end
