//
//  OPNavigationBar.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationTitle.h"
#import "NSWindow+FullScreen.h"
#import <Exposure/XPSharingService.h>
#import "OPNavigationController.h"
#import "OPNavigationViewController.h"
#import "OPCameraService.h"

NSString *const OPNavigationTitleFilterDidChange = @"OPNavigationTitleFilterDidChange";
NSString *const OPNavigationSearchFilterDidChange = @"OPNavigationSearchFilterDidChange";

@implementation OPNavigationTitle

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [_viewLabel setFont:[NSFont titleBarFontOfSize:[NSFont systemFontSize]]];
    
    _shareWithButton.menu = [[NSMenu alloc] init];
    _shareWithButton.menu.showsStateColumn = NO;
    _shareWithButton.menu.delegate = self;
    _shareWithButton.target = self;
    _shareWithButton.action = @selector(showSharingMenu:);
    
    [self setPostsBoundsChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraAdded:) name:@"OPCameraServiceDidAddCamera" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationControllerChanged:) name:OPNavigationControllerViewDidChange object:_navigationController];
    
    _isAlbums = YES;
    
    [self albumMode];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPNavigationControllerViewDidChange object:nil];
}

-(void)cameraAdded:(NSNotification*)notification
{
    [self cameraMode];
}

-(void)navigationControllerChanged:(NSNotification*)notification
{
    if (!_navigationController.isRootViewControllerVisible)
    {
        [self backMode];
    }
    
    if ([_navigationController.visibleViewController conformsToProtocol:@protocol(XPSharingService)])
    {
        id<XPSharingService> sharingService = (id<XPSharingService>)_navigationController.visibleViewController;
        
        if ([sharingService sharingMenuItems].count > 0)
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

-(void)updateTitle:(NSString *)title
{
    [_viewLabel.animator setStringValue:title];
}

- (IBAction)goBack:(id)sender
{
    [_navigationController popToPreviousViewController];
}

- (IBAction)switchViewButtonPressed:(NSButton*)sender
{
    if (_navigationController.isRootViewControllerVisible)
    {
        _isAlbums = !_isAlbums;
        
        if (_isAlbums)
        {
            [self albumMode];
        }
        else
        {
            [self cameraMode];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OPNavigationTitleFilterDidChange object:nil userInfo:@{@"isAlbumView": [NSNumber numberWithBool:_isAlbums]}];
    }
    else
    {
        [self backMode];
        [_navigationController popToPreviousViewController];
        if (_navigationController.isRootViewControllerVisible)
        {
            _isAlbums = !_isAlbums;
            
            if (_isAlbums)
            {
                [self albumMode];
            }
            else
            {
                [self cameraMode];
            }
        }
    }
}

-(void)cameraMode
{
    _switchViewButton.title = @"Albums";
    _switchViewButton.image = nil;
    _switchViewButton.frame = NSMakeRect(_switchViewButton.frame.origin.x, _switchViewButton.frame.origin.y, 69, _switchViewButton.frame.size.height);
    _searchFilter.stringValue = @""; //Clear
}

-(void)albumMode
{
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

-(void)showSharingMenu:(NSButton*)sender
{
    NSPoint point = _shareWithButton.frame.origin;
    point = NSMakePoint(point.x + 4, point.y + self.window.frame.size.height - 40);
    
    NSEvent *fakeMouseEvent = [NSEvent mouseEventWithType:NSLeftMouseDown
                                                 location:point
                                            modifierFlags:0
                                                timestamp:0
                                             windowNumber:[self.window windowNumber]
                                                  context:nil
                                              eventNumber:0
                                               clickCount:0
                                                 pressure:0];
    
    
    [NSMenu popUpContextMenu:[sender menu] withEvent:fakeMouseEvent forView:sender];
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

- (IBAction)searchFilter:(id)sender
{
    if (!_navigationController.isRootViewControllerVisible)
    {
        [_navigationController popToRootViewControllerWithNoAnimation];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OPNavigationSearchFilterDidChange object:nil userInfo:@{@"value":[sender stringValue]}];
    
    [self albumMode];
}

@end
