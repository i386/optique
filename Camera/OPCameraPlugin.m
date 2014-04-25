//
//  OPCameraPlugin.m
//  Optique
//
//  Created by James Dumay on 7/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraPlugin.h"
#import "NSImage+CGImage.h"
#import "OPCameraPreferencesViewController.h"

@implementation OPCameraPlugin

-(id)init
{
    self = [super init];
    if (self)
    {
        NSImage *image = [NSImage imageNamed:@"lock"];
        
        _badgeLayer = [XPBadgeLayer layer];
        _badgeLayer = [XPBadgeLayer layer];
        _badgeLayer.contents = (id)image.CGImageRef;
        _badgeLayer.bounds = NSMakeRect(0, 0, 128, 128);
        _badgeLayer.position = NSMakePoint(140, 87.5);
    }
    return self;
}

-(void)pluginDidLoad:(NSDictionary *)userInfo
{
    _cameraService = [[OPCameraService alloc] init];
    _cameraService.cameraPlugin = self;
    _collections = [NSMutableSet set];
}

-(void)pluginWillUnload:(NSDictionary *)userInfo
{
    //Remove all the caches if any exist
    if (_cameraService)
    {
        [_cameraService removeCaches];
    }
    
    [_collections removeAllObjects];
}

-(void)setCollectionManager:(XPCollectionManager *)collectionManager
{
    [_cameraService setCollectionManager:collectionManager];
    if (!_cameraService.deviceBrowser.isBrowsing)
    {
        [_cameraService start];
    }
    else
    {
        [_cameraService stop];
        [_cameraService start];
    }
}

-(CALayer *)badgeLayerForCollection:(id<XPItemCollection>)collection
{
    if ([collection isKindOfClass:[OPCamera class]])
    {
        OPCamera *camera  = (OPCamera*)collection;
        if (camera.isLocked)
        {
            return _badgeLayer;
        }
    }
    return nil;
}

-(NSArray *)preferenceViewControllers
{
    OPCameraPreferencesViewController *controller = [[OPCameraPreferencesViewController alloc] init];
    return @[controller];
}

-(NSArray *)debugMenuItems
{
    XPMenuItem *resetPreferredDeviceItem = [[XPMenuItem alloc] initWithTitle:@"Reset preffered devices" keyEquivalent:@"" block:^(NSMenuItem *sender) {
        for (OPCamera *camera in _cameraService.allCameras)
        {
            [camera setDefaultApp:NO];
        }
    }];
    
    XPMenuItem *clearCacheItem = [[XPMenuItem alloc] initWithTitle:@"Clear cache" keyEquivalent:@"" block:^(NSMenuItem *sender) {
       [_cameraService removeCaches];
    }];
    return @[resetPreferredDeviceItem, clearCacheItem];
}

@end
