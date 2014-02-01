//
//  OPMainWindowController.m
//  Optique
//
//  Created by James Dumay on 26/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPMainWindowController.h"
#import "OPNavigationController.h"
#import "OPItemCollectionViewController.h"
#import "OPCameraCollectionViewController.h"
#import "XPNavigationViewController.h"
#import "OPToolbarController.h"
#import "OPPItemViewController.h"
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

-(id)initWithCollectionManager:(XPCollectionManager *)collectionManager
{
    self = [super init];
    if (self)
    {
        _collectionManager = collectionManager;
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
    
    _albumViewController = [[OPCollectionViewController alloc] initWithCollectionManager:_collectionManager
                                                                              title:@"Albums"
                                                                       emptyMessage:@"Drop folders or photos here to add or create new albums"
                                                                               icon:[NSImage imageNamed:@"picture"]
                                                                collectionPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPItemCollection> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject collectionType] == XPItemCollectionLocal || [evaluatedObject collectionType] == XPItemCollectionOther;
    }]];
    
    _cameraViewController = [[OPCameraCollectionViewController alloc] initWithCollectionManager:_collectionManager
                                                                               title:@"Cameras"
                                                                        emptyMessage:@"There are no cameras connected"
                                                                                icon:[NSImage imageNamed:@"camera"]
                                                                 collectionPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPItemCollection> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject collectionType] == XPItemCollectionCamera;
    }]];
    
    [self addNavigationController:_albumViewController];
    
    [XPExposureService sidebarControllerWasCreated:self];
    [XPExposureService registerToolbar:_toolbar];
}

-(void)addNavigationController:(NSViewController*)viewController
{
    if (_navigationController)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:OPNavigationControllerViewDidChange object:_navigationController];
    }
    
    _navigationController = [[OPNavigationController alloc] initWithRootViewController:viewController];
    [XPExposureService navigationControllerWasCreated:_navigationController];
    
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
        
        NSView *contentView = self.window.contentView;
        
        CGFloat leftHandWidth = contentView.frame.size.width - kMaxSplitViewWidth;

        _leftSplitView.frame = NSMakeRect(0, 0, leftHandWidth, contentView.frame.size.height);
        _rightSplitView.frame = NSMakeRect(0, 0, kMaxSplitViewWidth, contentView.frame.size.height);
        _navigationController.view.frame = _leftSplitView.frame;
        viewController.view.frame = NSMakeRect(0, 0, kMaxSplitViewWidth, contentView.frame.size.height);

        [_rightSplitView addSubview:viewController.view];
        
        if ([viewController conformsToProtocol:@protocol(XPSidebar)])
        {
            [((id<XPSidebar>)viewController) activate];
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
        _searchViewController = [[OPCollectionViewController alloc] initWithCollectionManager:_collectionManager
                                                                                   title:title
                                                                            emptyMessage:@"There were no matches"
                                                                                    icon:[NSImage imageNamed:@"search"]
                                                                     collectionPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPItemCollection> evaluatedObject, NSDictionary *bindings) {
            return ([evaluatedObject collectionType] == XPItemCollectionLocal || [evaluatedObject collectionType] == XPItemCollectionOther) && [[NSPredicate predicateWithFormat:@"self.title contains[cd] %@", value] evaluateWithObject:evaluatedObject];
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
    return _sidebarViewController ? kOPSplitViewDividerThicknessCocoa : kOPSplitViewDividerThicknessNone;
}

- (IBAction)newAlbum:(id)sender
{
    OPNewAlbumPanelViewController *controller = [[OPNewAlbumPanelViewController alloc] initWithCollectionManager:_collectionManager sidebarController:self];
    [self showSidebarWithViewController:controller];
}

@end
