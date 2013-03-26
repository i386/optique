//
//  OPMainWindowController.m
//  Optique
//
//  Created by James Dumay on 26/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPMainWindowController.h"
#import <INAppStoreWindow/INAppStoreWindow.h>

@interface OPMainWindowController ()

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
    
    NSView *contentView = self.window.contentView;
    
    _albumViewController = [[OPAlbumViewController alloc] initWithPhotoManager:_photoManager];
    [self.window.contentView addSubview:_albumViewController.view];
    [_albumViewController.view setFrame:contentView.frame];
}

@end
