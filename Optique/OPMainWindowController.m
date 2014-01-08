//
//  OPMainWindowController.m
//  Optique
//
//  Created by James Dumay on 26/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPMainWindowController.h"
#import "OPNavigationController.h"
#import "OPPhotoCollectionViewController.h"
#import "OPCameraCollectionViewController.h"
#import "OPNavigationViewController.h"
#import "OPToolbarController.h"
#import "OPPhotoViewController.h"
#import "OPNewAlbumPanelViewController.h"
#import "NSWindow+FullScreen.h"

#define kMaxSplitViewWidth 300
#define kSidebarIndex 1

@interface OPMainWindowController () {
    OPNavigationController *_navigationController;
    OPCollectionViewController *_albumViewController;
    OPCameraCollectionViewController *_cameraViewController;
    OPCollectionViewController *_searchViewController;
}

@property (strong) NSViewController *sidebarViewController;

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
    
    //Set weak ref to nav controller
    _toolbarViewController.navigationController = _navigationController;
    
    NSView *contentView = _leftSplitView;
    [_navigationController.view setFrame:_leftSplitView.frame];
    
    [[contentView subviews] each:^(id sender) {
        [sender removeFromSuperview];
    }];

    [contentView addSubview:_navigationController.view positioned:NSWindowBelow relativeTo:nil];
}

-(void)showSidebarWithViewController:(NSViewController *)viewController
{
    //Do not open another sidebar unless there is no sidebar showing
    if (!_sidebarViewController)
    {
        _sidebarViewController = viewController;
        
        [_rightSplitView setHidden:NO];
        
        CGFloat leftHandWidth = _splitView.frame.size.width - kMaxSplitViewWidth;

        _leftSplitView.frame = NSMakeRect(_leftSplitView.frame.origin.x, _leftSplitView.frame.origin.y, leftHandWidth, _leftSplitView.frame.size.height);

        _rightSplitView.frame = NSMakeRect(_rightSplitView.frame.origin.x, _rightSplitView.frame.origin.y, kMaxSplitViewWidth, _rightSplitView.frame.size.height);

        _navigationController.view.frame = _leftSplitView.frame;
        
        [_rightSplitView addSubview:viewController.view];
        viewController.view.frame = NSMakeRect(0, 0, kMaxSplitViewWidth, _splitView.frame.size.height);
        
        if ([viewController conformsToProtocol:@protocol(OPWindowSidebar)])
        {
            [((id<OPWindowSidebar>)viewController) activate];
        }
    }
}

-(void)hideSidebar
{
    [_rightSplitView setHidden:YES];
    _leftSplitView.frame = NSMakeRect(0, 0, self.window.frame.size.width, self.window.frame.size.height);
    _sidebarViewController = nil;
    [[_rightSplitView subviews] each:^(id sender) {
        [sender removeFromSuperview];
    }];
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterChanged:) name:OPApplicationModeDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFilterChanged:) name:OPAlbumSearchFilterDidChange object:nil];
    [_rightSplitView setHidden:YES];
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
}

-(NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions
{
    return (NSApplicationPresentationFullScreen |
            NSApplicationPresentationHideDock |
            NSApplicationPresentationAutoHideMenuBar |
            NSApplicationPresentationAutoHideToolbar);
}

-(NSRect)splitView:(NSSplitView *)splitView effectiveRect:(NSRect)proposedEffectiveRect forDrawnRect:(NSRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex
{
    //Disables the split view control when no side bar is present
    if (!_sidebarViewController)
    {
        return NSZeroRect;
    }
    return proposedEffectiveRect;
}

-(BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
    return ![view isEqual:_rightSplitView];
}

-(CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if (dividerIndex == kSidebarIndex)
    {
        return kMaxSplitViewWidth;
    }
    return proposedMinimumPosition;
}

-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if (dividerIndex == kSidebarIndex)
    {
        return kMaxSplitViewWidth;
    }
    return proposedMaximumPosition;
}

-(CGFloat)dividerThickness
{
    return _sidebarViewController ? -1 : 0;
}

- (IBAction)newAlbum:(id)sender
{
    OPNewAlbumPanelViewController *controller = [[OPNewAlbumPanelViewController alloc] initWithPhotoManager:_photoManager sidebarController:self];
    [self showSidebarWithViewController:controller];
}

@end
