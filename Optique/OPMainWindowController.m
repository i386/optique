//
//  OPMainWindowController.m
//  Optique
//
//  Created by James Dumay on 26/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPMainWindowController.h"
#import "OPWindow.h"

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
    
    OPWindow *iWindow = (OPWindow*)self.window;
    
    _albumViewController = [[OPAlbumViewController alloc] initWithPhotoManager:_photoManager];
    
    _navigationController = [[OPNavigationController alloc] initWithRootViewController:_albumViewController];
    
    NSView *contentView = self.window.contentView;
    [self.window.contentView addSubview:_navigationController.view];
    [_navigationController.view setFrame:contentView.frame];
    
    NSView *navigationBar = _navigationController.navigationBar;
    
    [iWindow.titleBarView addSubview:navigationBar];
//    
//    NSRect navigationBarRect = NSMakeRect(navigationBar.frame.origin.x + 65, navigationBar.frame.origin.y, navigationBar.frame.size.width, navigationBar.frame.size.height);
//    
//    [navigationBar setFrame:navigationBarRect];
}

-(void)windowDidEnterFullScreen:(NSNotification *)notification
{
    [_navigationController updateNavigationBar];
}

-(void)windowDidExitFullScreen:(NSNotification *)notification
{
    [_navigationController updateNavigationBar];
}

@end
