//
//  OPDeviceImageCapture.m
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraService.h"
#import "OPCamera.h"

NSString *const OPCameraServiceDidAddCamera = @"OPCameraServiceDidAddCamera";
NSString *const OPCameraServiceDidRemoveCamera = @"OPCameraServiceDidRemoveCamera";

@interface OPCameraService() {
    NSMutableDictionary *_devices;
}

@end

@implementation OPCameraService

-(id)init
{
    self = [super init];
    if (self)
    {
        _devices = [NSMutableDictionary dictionary];
        _deviceBrowser = [[ICDeviceBrowser alloc] init];
        _deviceBrowser.delegate = self;
        _deviceBrowser.browsedDeviceTypeMask = _deviceBrowser.browsedDeviceTypeMask | ICDeviceLocationTypeMaskLocal |ICDeviceLocationTypeMaskRemote|ICDeviceTypeMaskCamera;
    }
    return self;
}

-(void)restart
{
    [_deviceBrowser stop];
    [_deviceBrowser start];
}

-(void)deviceBrowser:(ICDeviceBrowser *)browser didAddDevice:(ICDevice *)device moreComing:(BOOL)moreComing
{
    OPCamera *camera = [[OPCamera alloc] initWithDevice:(ICCameraDevice*)device];
    [_devices setObject:camera forKey:device.name];
    
    [camera.device requestOpenSession];
    
    for (ICCameraFile *file in camera.device.mediaFiles)
    {
        [file largeThumbnailIfAvailable];
    }
    
    [self sendNotification:OPCameraServiceDidAddCamera camera:camera];
}

-(void)deviceBrowser:(ICDeviceBrowser *)browser didRemoveDevice:(ICDevice *)device moreGoing:(BOOL)moreGoing
{
    [self sendNotification:OPCameraServiceDidRemoveCamera camera:[_devices objectForKey:device.name]];
    [_devices removeObjectForKey:device.name];
//    [device requestCloseSession];
}

-(void)sendNotification:(NSString*)notificationName camera:(OPCamera*)camera
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"camera": camera}];
}

@end
