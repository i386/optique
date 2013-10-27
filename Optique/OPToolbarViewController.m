//
//  OPToolbarViewController.m
//  Optique
//
//  Created by James Dumay on 15/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPToolbarViewController.h"
#import "OPNavigationViewController.h"

NSString *const OPApplicationModeDidChange = @"OPApplicationModeDidChange";
NSString *const OPAlbumSearchFilterDidChange = @"OPAlbumSearchFilterDidChange";
NSString *const OPSharableSelectionChanged = @"OPSharableSelectionChanged";

@interface OPToolbarViewController ()

@end

@implementation OPToolbarViewController

- (id)init
{
    self = self = [super initWithNibName:@"OPToolbarViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    _shareWithButton.menu = [[NSMenu alloc] init];
    _shareWithButton.menu.showsStateColumn = NO;
    _shareWithButton.menu.delegate = self;
    
    [self.view setPostsBoundsChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraAdded:) name:@"OPCameraServiceDidAddCamera" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharableSelectionChanged:) name:OPNavigationControllerViewDidChange object:_navigationController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharableSelectionChanged:) name:OPSharableSelectionChanged object:nil];
    
    [self albumMode];
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

-(void)sharableSelectionChanged:(NSNotification*)notification
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
