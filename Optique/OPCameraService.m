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
    OPPhotoManager *_photoManager;
    NSMutableDictionary *_devices;
}

@end

@implementation OPCameraService

-(id)initWithPhotoManager:(OPPhotoManager *)photoManager
{
    self = [super init];
    if (self)
    {
        _photoManager = photoManager;
        _devices = [NSMutableDictionary dictionary];
        _deviceBrowser = [[ICDeviceBrowser alloc] init];
        _deviceBrowser.delegate = self;
        _deviceBrowser.browsedDeviceTypeMask = _deviceBrowser.browsedDeviceTypeMask | ICDeviceLocationTypeMaskLocal |ICDeviceLocationTypeMaskRemote|ICDeviceTypeMaskCamera;
    }
    return self;
}

-(NSArray *)allCameras
{
    return _devices.allValues;
}

-(void)start
{
    [_deviceBrowser start];
}

-(void)stop
{
    [_deviceBrowser stop];
}

-(void)removeCaches
{
    [_devices.allValues each:^(OPCamera *camera) {
       [self performBlockInBackground:^{
           [camera removeCacheDirectory];
       }];
    }];
}

-(void)deviceBrowser:(ICDeviceBrowser *)browser didAddDevice:(ICDevice *)device moreComing:(BOOL)moreComing
{
    ICCameraDevice *cameraDevice = (ICCameraDevice*)device;
    
#if DEBUG
    NSLog(@"Found camera '%@'", cameraDevice.name);
    if (cameraDevice.isAccessRestrictedAppleDevice)
    {
        NSLog(@"The camera '%@' is locked", cameraDevice.name);
    }
#endif
    
    OPCamera *camera = [[OPCamera alloc] initWithDevice:cameraDevice photoManager:_photoManager];
    [camera removeCacheDirectory];
    
    [_devices setObject:camera forKey:device.name];
    
    [camera.device requestOpenSession];
    
    [self sendNotification:OPCameraServiceDidAddCamera camera:camera userInfo:@{@"locked": [NSNumber numberWithBool:cameraDevice.isAccessRestrictedAppleDevice]}];
}

-(void)deviceBrowser:(ICDeviceBrowser *)browser didRemoveDevice:(ICDevice *)device moreGoing:(BOOL)moreGoing
{
#if DEBUG
    NSLog(@"Remove camera camera '%@'", device.name);
#endif
    
    OPCamera *camera = [_devices objectForKey:device.name];
    [self sendNotification:OPCameraServiceDidRemoveCamera camera:camera userInfo:nil];
    [_devices removeObjectForKey:device.name];
    [camera removeCacheDirectory];
}

-(void)sendNotification:(NSString*)notificationName camera:(OPCamera*)camera userInfo:(NSDictionary*)userInfo
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [dict setObject:camera forKey:@"camera"];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dict];
}

@end
