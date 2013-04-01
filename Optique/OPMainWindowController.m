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

-(id)initWithPhotoManager:(OPPhotoManager *)photoManager
{
    self = [super init];
    if (self)
    {
        _photoManager = photoManager;
    }
    return self;
}

-(NSString *)windowNibName
{
    return @"OPMainWindowController";
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    _albumViewController = [[OPAlbumViewController alloc] initWithPhotoManager:_photoManager];
    _navigationController = [[OPNavigationController alloc] initWithRootViewController:_albumViewController];
    
    OPWindow *window = (OPWindow*)self.window;
    NSView *contentView = window.contentView;
    [window.contentView addSubview:_navigationController.view];
    [_navigationController.view setFrame:contentView.frame];
    [window.titleBarView addSubview:(NSView*)_navigationController.navigationBar];
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
