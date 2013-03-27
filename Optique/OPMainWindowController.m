//
//  OPMainWindowController.m
//  Optique
//
//  Created by James Dumay on 26/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPMainWindowController.h"
#import <INAppStoreWindow/INAppStoreWindow.h>

#import "OPNavigationController.h"

@interface OPMainWindowController () {
    OPNavigationController *_navigationController;
}

@end

@implementation OPMainWindowController

-(NSString *)windowNibName
{
    return @"OPMainWindowController";
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    INAppStoreWindow *iWindow = (INAppStoreWindow*)self.window;
    iWindow.titleBarHeight = 36.0;
    
    _albumViewController = [[OPAlbumViewController alloc] initWithPhotoManager:_photoManager];
    
    _navigationController = [[OPNavigationController alloc] initWithRootViewController:_albumViewController];
    
    NSView *contentView = self.window.contentView;
    [self.window.contentView addSubview:_navigationController.view];
    [_navigationController.view setFrame:contentView.frame];
}

@end
