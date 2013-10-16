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
#import "OPNavigationViewController.h"
#import "OPToolbarViewController.h"

@interface OPMainWindowController () {
    OPNavigationController *_navigationController;
    OPCollectionViewController *_albumViewController;
    OPCollectionViewController *_cameraViewController;
    OPCollectionViewController *_searchViewController;
    OPNewAlbumSheetController *_newAlbumSheetController;
    OPToolbarViewController *_toolbarViewController;
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
    
    _toolbarViewController = [[OPToolbarViewController alloc] init];
    
    OPWindow *window = (OPWindow*)self.window;
    [window.titleBarView addSubview:(NSView*)_toolbarViewController.view];
    
    _albumViewController = [[OPCollectionViewController alloc] initWithPhotoManager:_photoManager
                                                                              title:@"Albums"
                                                                       emptyMessage:@"There are no albums"
                                                                               icon:[NSImage imageNamed:@"picture"]
                                                                collectionPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPhotoCollection> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject collectionType] == kPhotoCollectionLocal || [evaluatedObject collectionType] == kPhotoCollectionOther;
    }]];
    
    _cameraViewController = [[OPCollectionViewController alloc] initWithPhotoManager:_photoManager
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
    _navigationController = [[OPNavigationController alloc] initWithRootViewController:viewController];
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

@end
