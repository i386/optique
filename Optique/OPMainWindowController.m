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
#import "OPCameraCollectionViewController.h"
#import "OPNewAlbumSheetController.h"
#import "OPNavigationViewController.h"
#import "OPToolbarViewController.h"
#import "OPPhotoViewController.h"
#import "NSWindow+FullScreen.h"

@interface OPMainWindowController () {
    OPNavigationController *_navigationController;
    OPCollectionViewController *_albumViewController;
    OPCameraCollectionViewController *_cameraViewController;
    OPCollectionViewController *_searchViewController;
    OPNewAlbumSheetController *_newAlbumSheetController;
}

@end

@implementation OPMainWindowController

-(id)initWithPhotoManager:(XPPhotoManager *)photoManager
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

-(void)goBack
{
    [_navigationController popToPreviousViewController];
}

-(void)showAlbums
{
    [self addNavigationController:_albumViewController];
}

-(void)showCameras
{
    [self addNavigationController:_cameraViewController];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    _toolbarViewController = [[OPToolbarViewController alloc] init];
    
    OPWindow *window = (OPWindow*)self.window;
    [window.titleBarView addSubview:(NSView*)_toolbarViewController.view];
    
    _albumViewController = [[OPCollectionViewController alloc] initWithPhotoManager:_photoManager
                                                                              title:@"Albums"
                                                                       emptyMessage:@"Drop folders or photos here to add or create new albums"
                                                                               icon:[NSImage imageNamed:@"picture"]
                                                                collectionPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPhotoCollection> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject collectionType] == kPhotoCollectionLocal || [evaluatedObject collectionType] == kPhotoCollectionOther;
    }]];
    
    _cameraViewController = [[OPCameraCollectionViewController alloc] initWithPhotoManager:_photoManager
                                                                               title:@"Cameras"
                                                                        emptyMessage:@"There are no cameras connected"
                                                                                icon:[NSImage imageNamed:@"camera"]
                                                                 collectionPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPhotoCollection> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject collectionType] == kPhotoCollectionCamera;
    }]];
    
    [self addNavigationController:_albumViewController];
}

-(void)addNavigationController:(OPNavigationViewController*)viewController
{
    if (_navigationController)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:OPNavigationControllerViewDidChange object:_navigationController];
    }
    
    _navigationController = [[OPNavigationController alloc] initWithRootViewController:viewController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationControllerChanged:) name:OPNavigationControllerViewDidChange object:_navigationController];
    
    _newAlbumSheetController = [[OPNewAlbumSheetController alloc] initWithPhotoManager:_photoManager navigationController:_navigationController];
    
    //Set weak ref to nav controller
    _toolbarViewController.navigationController = _navigationController;
    
    OPWindow *window = (OPWindow*)self.window;
    NSView *contentView = (NSView*)window.contentView;
    [_navigationController.view setFrame:contentView.frame];
    
    [[contentView subviews] each:^(id sender) {
        [sender removeFromSuperview];
    }];

    [contentView addSubview:_navigationController.view positioned:NSWindowBelow relativeTo:nil];
}

-(void)showNewAlbumSheet
{
    [NSApp beginSheet:_newAlbumSheetController.window modalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterChanged:) name:OPApplicationModeDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFilterChanged:) name:OPAlbumSearchFilterDidChange object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPApplicationModeDidChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumSearchFilterDidChange object:nil];
}

-(void)cameraAdded:(NSNotification*)notification
{
    [self addNavigationController:_cameraViewController];
}

-(void)searchFilterChanged:(NSNotification*)notification
{
    NSString *value = notification.userInfo[@"value"];
    if ([value isEqualToString:@""])
    {
        [self addNavigationController:_albumViewController];
        _searchViewController = nil;
    }
    else
    {
        NSString *title = [NSString stringWithFormat:@"Search for '%@'", value];
        _searchViewController = [[OPCollectionViewController alloc] initWithPhotoManager:_photoManager
                                                                                   title:title
                                                                            emptyMessage:@"There were no matches"
                                                                                    icon:[NSImage imageNamed:@"search"]
                                                                     collectionPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPhotoCollection> evaluatedObject, NSDictionary *bindings) {
            return ([evaluatedObject collectionType] == kPhotoCollectionLocal || [evaluatedObject collectionType] == kPhotoCollectionOther) && [[NSPredicate predicateWithFormat:@"self.title contains[cd] %@", value] evaluateWithObject:evaluatedObject];
        }]];
        [self addNavigationController:_searchViewController];
    }
}

-(void)filterChanged:(NSNotification*)notification
{
    OPApplicationMode mode = [notification.userInfo[@"mode"] shortValue];
    
    if (mode == OPApplicationModeAlbum)
    {
        [self addNavigationController:_albumViewController];
    }
    else
    {
        NSString *cameraTitle = notification.userInfo[@"title"];
        [self addNavigationController:_cameraViewController];
        if (cameraTitle != nil)
        {
            [_cameraViewController showCollectionWithTitle:cameraTitle];
        }
    }
}

-(void)navigationControllerChanged:(NSNotification*)notification
{
    OPNavigationController *controllerForNotification = (OPNavigationController*)notification.object;
    
    if (!controllerForNotification.isRootViewControllerVisible)
    {
        [_toolbarViewController backMode];
    }
    else if (controllerForNotification.isRootViewControllerVisible &&
        [controllerForNotification.visibleViewController isEqual:_cameraViewController])
    {
        [_toolbarViewController cameraMode];
    }
    else if (controllerForNotification.isRootViewControllerVisible &&
             [controllerForNotification.visibleViewController isEqual:_albumViewController])
    {
        [_toolbarViewController albumMode];
    }
    else
    {
        NSLog(@"navigationControllerChanged but we ran out of things to do");
    }
    
    if ([_navigationController.visibleViewController isKindOfClass:[OPPhotoViewController class]] && self.window.isFullscreen)
    {
        [self hideToolbar];
    }
    else
    {
        [self showToolbar];
    }
}

-(void)windowWillEnterFullScreen:(NSNotification *)notification
{
    if ([_navigationController.visibleViewController isKindOfClass:[OPPhotoViewController class]])
    {
        [self hideToolbar];
    }
}

-(void)windowWillExitFullScreen:(NSNotification *)notification
{
    [self showToolbar];
}

-(void)hideToolbar
{
    OPWindow *window = (OPWindow*)self.window;
    window.animator.titleBarHeight = 0;
    [window.animator.titleBarView setHidden:YES];
}

-(void)showToolbar
{
    OPWindow *window = (OPWindow*)self.window;
    window.animator.titleBarHeight = 53;
    [window.animator.titleBarView setHidden:NO];
}

@end
