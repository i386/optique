//
//  OPCameraPlugin.m
//  Optique
//
//  Created by James Dumay on 7/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraPlugin.h"
#import "NSImage+CGImage.h"

@implementation OPCameraPlugin

-(void)pluginDidLoad:(NSDictionary *)userInfo
{
    _cameraService = [[OPCameraService alloc] init];
    _cameraService.cameraPlugin = self;
}

-(void)pluginWillUnload:(NSDictionary *)userInfo
{
    //Remove all the caches if any exist
    if (_cameraService)
    {
        [_cameraService removeCaches];
    }
}

-(void)photoManagerWasCreated:(XPPhotoManager *)photoManager
{
    [_cameraService setPhotoManager:photoManager];
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

-(CALayer *)badgeLayerForCollection:(id<XPPhotoCollection>)collection
{
    if ([collection isKindOfClass:[OPCamera class]])
    {
        OPCamera *camera  = (OPCamera*)collection;
        if (camera.isLocked)
        {
            NSImage *image = [NSImage imageNamed:@"lock"];
            
            XPBadgeLayer *layer = [XPBadgeLayer layer];
            XPBadgeLayer *imageLayer = [XPBadgeLayer layer];
            imageLayer.contents = (id)image.CGImageRef;
            imageLayer.bounds = NSMakeRect(0, 0, 128, 128);
            imageLayer.position = NSMakePoint(140, 87.5);
            
            [layer addSublayer:imageLayer];
            
            return layer;
        }
    }
    return nil;
}

-(NSArray *)debugMenuItems
{
    XPMenuItem *clearCacheItem = [[XPMenuItem alloc] initWithTitle:@"Clear cache" keyEquivalent:@"" block:^(NSMenuItem *sender) {
       [_cameraService removeCaches];
    }];
    return @[clearCacheItem];
}

@end
