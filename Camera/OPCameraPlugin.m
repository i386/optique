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

-(id)init
{
    self = [super init];
    if (self)
    {
        NSImage *image = [NSImage imageNamed:@"lock"];
        
        _badgeLayer = [XPBadgeLayer layer];
        _imageLayer = [XPBadgeLayer layer];
        _imageLayer.contents = (id)image.CGImageRef;
        _imageLayer.bounds = NSMakeRect(0, 0, 128, 128);
        _imageLayer.position = NSMakePoint(140, 87.5);
    }
    return self;
}

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
            return _badgeLayer;
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

-(void)dealloc
{
    CGImageRelease((CGImageRef)_imageLayer.contents);
}

@end
