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
#import "OPPhotoCollectionViewController.h"
#import "OPNewAlbumSheetController.h"
#import "OPMainWindowContentView.h"

@interface OPMainWindowController () {
    OPNavigationController *_navigationController;
    OPAlbumViewController *_albumViewController;
    OPNewAlbumSheetController *_newAlbumSheetController;
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

- (IBAction)navigateBack:(id)sender
{
    [self navigateBackward];
}

-(void)navigateBackward
{
    [_navigationController popToPreviousViewController];
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
    _newAlbumSheetController = [[OPNewAlbumSheetController alloc] initWithPhotoManager:_photoManager navigationController:_navigationController];
    _navigationController.delegate = self;
    
    OPWindow *window = (OPWindow*)self.window;
    OPMainWindowContentView *contentView = (OPMainWindowContentView*)window.contentView;
    [_navigationController.view setFrame:contentView.frame];
    [window.titleBarView addSubview:(NSView*)_navigationController.navigationTitle];
    
    contentView.navigationButton = _navBackButton;
    
    [contentView addSubview:_navigationController.view positioned:NSWindowBelow relativeTo:nil];
}

-(void)showBackButton:(BOOL)visible
{
    OPMainWindowContentView *contentView = (OPMainWindowContentView*)self.window.contentView;
    contentView.allowedToShowNavButton = visible;
    if (!visible)
    {
        [_navBackButton setHidden:!visible];
    }
}

-(void)showNewAlbumSheet
{
    [NSApp beginSheet:_newAlbumSheetController.window modalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

@end
