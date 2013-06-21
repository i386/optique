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

@implementation OPNavigationTitle

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidExitFullScreenNotification object:self.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEnterFullScreenNotification object:self.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPCameraServiceDidAddCamera object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPNavigationControllerViewDidChange object:nil];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    _shareWithButton.menu = [[NSMenu alloc] init];
    _shareWithButton.menu.showsStateColumn = NO;
    _shareWithButton.menu.delegate = self;
    _shareWithButton.target = self;
    _shareWithButton.action = @selector(showSharingMenu:);
    
    [self setPostsBoundsChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraAdded:) name:OPCameraServiceDidAddCamera object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationControllerChanged:) name:OPNavigationControllerViewDidChange object:_navigationController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidEnterFullScreen:) name:NSWindowDidEnterFullScreenNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidExitFullScreen:) name:NSWindowDidExitFullScreenNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillExitFullScreen:) name:NSWindowWillExitFullScreenNotification object:nil];
}

-(void)windowDidEnterFullScreen:(NSNotification*)notification
{
    _backButton.animator.frame = NSMakeRect(20, _backButton.frame.origin.y, _backButton.frame.size.width, _backButton.frame.size.height);
}

-(void)windowWillExitFullScreen:(NSNotification*)notification
{
    [_backButton setHidden:YES];
}

-(void)windowDidExitFullScreen:(NSNotification*)notification
{
    _backButton.frame = NSMakeRect(97, _backButton.frame.origin.y, _backButton.frame.size.width, _backButton.frame.size.height);
    [_backButton setHidden:NO];
}

-(void)cameraAdded:(NSNotification*)notification
{
    [_cameraButton setSelectedSegment:1];
}

-(void)navigationControllerChanged:(NSNotification*)notification
{
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
    OPNavigationViewController *previousViewController = [_navigationController peekAtPreviousViewController];
    
    if (previousViewController)
    {
        NSString *title = previousViewController == _navigationController.rootViewController ? @"Albums" : previousViewController.viewTitle;
        
        [_backButton setTitle:title];
    }
    
    [self.window setTitle:title];
    [_viewLabel.animator setStringValue:title];
}

- (IBAction)goBack:(id)sender
{
    [_navigationController popToPreviousViewController];
}

- (IBAction)cameraButtonPressed:(NSSegmentedControl*)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OPNavigationTitleFilterDidChange object:nil userInfo:@{@"segment": [NSNumber numberWithInteger:sender.selectedSegment]}];
}

- (IBAction)deleteButtonPressed:(id)sender
{
    if ([_navigationController.visibleViewController conformsToProtocol:@protocol(XPController)])
    {
        id<XPController> controller = (id<XPController>)_navigationController.visibleViewController;
        [controller deleteSelected];
    }
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

-(void)doNothing:(id)obj
{
    //Fuck appkit sucks
}

@end
