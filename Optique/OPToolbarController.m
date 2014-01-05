//
//  OPToolbarViewController.m
//  Optique
//
//  Created by James Dumay on 15/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPToolbarController.h"
#import "OPNavigationViewController.h"
#import "OPHistoryPeekViewController.h"

NSString *const OPApplicationModeDidChange = @"OPApplicationModeDidChange";
NSString *const OPAlbumSearchFilterDidChange = @"OPAlbumSearchFilterDidChange";
NSString *const OPSharableSelectionChanged = @"OPSharableSelectionChanged";

@interface OPToolbarController ()

@property (strong) OPHistoryPeekViewController *peekViewController;

@end

@implementation OPToolbarController

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [_loadProgressIndicator setDisplayedWhenStopped:NO];
    
    __block NSProgressIndicator *indicatorForBlock = _loadProgressIndicator;
    
    _syncCollectionEvents = [OPNotificationSynchronizer watchForIncrementNotification:XPPhotoCollectionDidStartLoading
                                                             deincrementNotification:XPPhotoCollectionDidStopLoading
                                                                       incrementBlock:^{
                                                                        [indicatorForBlock setHidden:NO];
                                                                        [indicatorForBlock startAnimation:self];
    }
                                                                    deincrementBlock:^{
                                                                        [indicatorForBlock setHidden:YES];
                                                                        [indicatorForBlock stopAnimation:self];
    }];
    
    _shareWithButton.menu = [[NSMenu alloc] init];
    _shareWithButton.menu.showsStateColumn = NO;
    _shareWithButton.menu.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraAdded:) name:@"OPCameraServiceDidAddCamera" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareableSelectionHasChanged:) name:OPSharableSelectionChanged object:nil];
    
    [self albumMode];
}

-(void)setNavigationController:(OPNavigationController *)navigationController
{
    if (_navigationController)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:OPNavigationControllerViewDidChange object:_navigationController];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationControllerViewDidChange:) name:OPNavigationControllerViewDidChange object:navigationController];
    
    _navigationController = navigationController;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPNavigationControllerViewDidChange object:_navigationController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OPCameraServiceDidAddCamera" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPSharableSelectionChanged object:nil];
}

-(void)cameraAdded:(NSNotification*)notification
{
    [self cameraMode];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OPApplicationModeDidChange object:nil userInfo:@{@"mode": [NSNumber numberWithBool:_filterMode], @"title":notification.userInfo[@"title"]}];
}

-(void)shareableSelectionHasChanged:(NSNotification*)notification
{
    if ([_navigationController.visibleViewController conformsToProtocol:@protocol(XPSharingService)])
    {
        id<XPSharingService> sharingService = (id<XPSharingService>)_navigationController.visibleViewController;
        
        if ([sharingService sharingMenuItems].count > 0 && [sharingService shareableItemsSelected])
        {
            [_shareWithButton setEnabled:YES];
        }
        else
        {
            [_shareWithButton setEnabled:NO];
        }
    }
    else
    {
        [_shareWithButton setEnabled:NO];
    }
}

-(void)navigationControllerViewDidChange:(NSNotification*)notification
{
    NSArray *items = nil;
    
    OPNavigationViewController *viewController = _navigationController.peekAtPreviousViewController;
    if (viewController && [viewController conformsToProtocol:@protocol(XPPhotoCollectionViewController)])
    {
        id<XPPhotoCollectionViewController> photoCollectionViewController = (id<XPPhotoCollectionViewController>)viewController;
        items = [[[photoCollectionViewController visibleCollection] allPhotos] array];
    }
    else if (viewController && [viewController conformsToProtocol:@protocol(XPCollectionViewController)])
    {
        id<XPCollectionViewController> collectionViewController = (id<XPCollectionViewController>)viewController;
        items = [collectionViewController collections];
    }
    else if ([_navigationController.visibleViewController conformsToProtocol:@protocol(XPPhotoController)])
    {
        _switchViewButton.peek = YES;
    }
    else
    {
        _switchViewButton.peek = NO;
    }
    
    if (items && ![_peekViewController.popover isShown])
    {
        _peekViewController = [[OPHistoryPeekViewController alloc] initWithItems:items navigationController:_navigationController];
        _switchViewButton.historyPeekViewController = _peekViewController;
        _switchViewButton.peek = YES;
    }
}

- (IBAction)switchViewButtonPressed:(NSButton*)sender
{
    if (_navigationController.isRootViewControllerVisible)
    {
        if (_filterMode == OPApplicationModeAlbum)
        {
            _filterMode = OPApplicationModeCamera;
        }
        else
        {
            _filterMode = OPApplicationModeAlbum;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OPApplicationModeDidChange object:nil userInfo:@{@"mode": [NSNumber numberWithBool:_filterMode]}];
    }
    else
    {
        [_navigationController popToPreviousViewController];
    }
}

-(void)cameraMode
{
    _filterMode = OPApplicationModeCamera;
    _switchViewButton.title = @"Albums";
    _switchViewButton.image = nil;
    _switchViewButton.frame = NSMakeRect(_switchViewButton.frame.origin.x, _switchViewButton.frame.origin.y, 69, _switchViewButton.frame.size.height);
    _searchFilter.stringValue = @""; //Clear
}

-(void)albumMode
{
    _filterMode = OPApplicationModeAlbum;
    _switchViewButton.title = @"Cameras";
    _switchViewButton.image = nil;
    _switchViewButton.frame = NSMakeRect(_switchViewButton.frame.origin.x, _switchViewButton.frame.origin.y, 72, _switchViewButton.frame.size.height);
}

-(void)backMode
{
    _switchViewButton.title = @"Back";
    _switchViewButton.image = [NSImage imageNamed:NSImageNameGoLeftTemplate];
    _switchViewButton.frame = NSMakeRect(_switchViewButton.frame.origin.x, _switchViewButton.frame.origin.y, 65, _switchViewButton.frame.size.height);
}

-(void)menuNeedsUpdate:(NSMenu *)menu
{
    if (menu.itemArray.count < 1 && [_navigationController.visibleViewController conformsToProtocol:@protocol(XPSharingService)])
    {
        id<XPSharingService> sharingService = (id<XPSharingService>)_navigationController.visibleViewController;
        
        [[sharingService sharingMenuItems] each:^(id sender) {
            [menu addItem:sender];
        }];
    }
}

- (IBAction)sharingButtonActivated:(id)sender
{
    NSLog(@"sharingButtonActivated");
}

- (IBAction)searchFilter:(id)sender
{
    if (!_navigationController.isRootViewControllerVisible)
    {
        [_navigationController popToRootViewControllerWithNoAnimation];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OPAlbumSearchFilterDidChange object:nil userInfo:@{@"value":[sender stringValue]}];
    
    [self albumMode];
}
@end