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

-(void)updateTitle:(NSString *)title
{
    [self.window setTitle:title];
    [_viewLabel setStringValue:title];
    
    if (self.window.isFullscreen)
    {
        [_viewLabel.animator setHidden:NO];
    }
    else
    {
        [_viewLabel.animator setHidden:YES];
    }
}

@end
