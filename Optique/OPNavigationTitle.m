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
    [shareButton setImage:[NSImage imageNamed:NSImageNameShareTemplate]];
    shareButton.menu.delegate = self;
    shareButton.target = self;
    shareButton.action = @selector(showSharingMenu:);
    
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
    [_cameraButton setState:NSOnState];
}

-(void)navigationControllerChanged:(NSNotification*)notification
{
    if ([_navigationController.visibleViewController conformsToProtocol:@protocol(XPSharingService)])
    {
        id<XPSharingService> sharingService = (id<XPSharingService>)_navigationController.visibleViewController;
        
        if ([sharingService sharingMenuItems].count > 0)
        {
            [shareButton setEnabled:YES];
        }
        else
        {
            [shareButton setEnabled:NO];
        }
    }
    else
    {
        [shareButton setEnabled:NO];
    }
}

-(void)updateTitle:(NSString *)title
{
    [_backButton.animator setTitle:self.window.title];
    [self.window setTitle:title];
    [_viewLabel.animator setStringValue:title];
}

- (IBAction)goBack:(id)sender
{
    [_navigationController popToPreviousViewController];
}

- (IBAction)cameraButtonPressed:(NSButton*)sender
{
    int selected = sender.state ? NSOffState : NSOnState;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OPNavigationTitleFilterDidChange object:nil userInfo:@{@"segment": [NSNumber numberWithInteger:selected]}];
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
    [NSMenu popUpContextMenu:[sender menu] withEvent:[NSApplication sharedApplication].currentEvent forView:sender];
}

-(void)menuNeedsUpdate:(NSMenu *)menu
{
    if ([_navigationController.visibleViewController conformsToProtocol:@protocol(XPSharingService)])
    {
        id<XPSharingService> sharingService = (id<XPSharingService>)_navigationController.visibleViewController;
        
        [[sharingService sharingMenuItems] each:^(id sender) {
            [menu addItem:sender];
        }];
    }
}

@end
