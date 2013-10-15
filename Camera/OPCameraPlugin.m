//
//  OPCameraPlugin.m
//  Optique
//
//  Created by James Dumay on 7/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraPlugin.h"

@implementation OPCameraPlugin

-(CALayer *)badgeLayerForCollection:(id<XPPhotoCollection>)collection
{
    if ([collection isKindOfClass:[OPCamera class]])
    {
        XPBadgeLayer *badgeLayer = [XPBadgeLayer layer];
        CATextLayer *layer = [CATextLayer layer];
        layer.string = @"Camera";
        [badgeLayer addSublayer:layer];
        return badgeLayer;
    }
    return nil;
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

-(void)didAddCamera:(OPCamera *)camera
{
    [_photoCollections addObject:camera];
    [_delegate didAddPhotoCollection:camera];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OPCameraServiceDidAddCamera" object:nil userInfo:@{@"title": camera.title}];
}

-(void)didRemoveCamera:(OPCamera *)camera
{
    [_photoCollections removeObject:camera];
    [_delegate didRemovePhotoCollection:camera];
}

-(NSArray *)debugMenuItems
{
    XPMenuItem *clearCacheItem = [[XPMenuItem alloc] initWithTitle:@"Clear cache" keyEquivalent:@"" block:^(NSMenuItem *sender) {
       [_cameraService removeCaches];
    }];
    return @[clearCacheItem];
}

@end
