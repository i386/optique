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

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraAdded:) name:OPCameraServiceDidAddCamera object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillExitFullScreenNotification object:self.window];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationControllerChanged:) name:OPNavigationControllerViewDidChange object:_navigationController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameChanged:) name:NSViewFrameDidChangeNotification object:self];
}

-(void)cameraAdded:(NSNotification*)notification
{
    [filterSegmentedControl setSelectedSegment:OPNavigationTitleFilterDevices];
}

-(void)frameChanged:(NSNotification*)notification
{
    NSLog(@"Bounds changed");
    
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
    [self.window setTitle:title];
    [_viewLabel.animator setStringValue:title];
    
    
    //Refloat the back button when the title updates
    NSRect boundsOfText = [_viewLabel.attributedStringValue boundingRectWithSize:_viewLabel.frame.size options:NSStringDrawingUsesDeviceMetrics];
    
    float xPositionOfButton = ((_viewLabel.frame.size.width - boundsOfText.size.width) / 2) - _backButton.frame.size.width;
    
    _backButton.animator.frame = NSMakeRect(xPositionOfButton, _backButton.frame.origin.y, _backButton.frame.size.width, _backButton.frame.size.height);
}

- (IBAction)goBack:(id)sender
{
    [_navigationController popToPreviousViewController];
}

- (IBAction)filterSegmentChanged:(NSSegmentedControl*)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OPNavigationTitleFilterDidChange object:nil userInfo:@{@"segment": [NSNumber numberWithInteger:sender.selectedSegment]}];
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
