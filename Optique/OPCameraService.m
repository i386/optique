//
//  OPDeviceImageCapture.m
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraService.h"
#import "OPCamera.h"
#import "OPCameraPlugin.h"

@interface OPCameraService()

@property (strong) NSMutableDictionary *devices;
@property (strong) NSRunLoop *loop;

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
        _loop = [[NSRunLoop alloc] init];
    }
    return self;
}

-(NSArray *)allCameras
{
    return _devices.allValues;
}

-(void)start
{
    [_deviceBrowser stop];
    [_deviceBrowser start];
}

-(void)stop
{
    [_deviceBrowser stop];
    [_devices removeAllObjects];
}

-(void)removeCaches
{
    for (OPCamera *camera in _devices.allValues)
    {
        [camera removeCacheDirectory];
    }
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
    
    OPCamera *camera = [[OPCamera alloc] initWithDevice:cameraDevice collectionManager:_collectionManager service:self];
    [camera removeCacheDirectory];
    
    [_devices setObject:camera forKey:device.name];
    
    [camera.device requestOpenSession];
}

-(void)deviceBrowser:(ICDeviceBrowser *)browser didRemoveDevice:(ICDevice *)device moreGoing:(BOOL)moreGoing
{
#if DEBUG
    NSLog(@"Remove camera camera '%@'", device.name);
#endif
    
    OPCamera *camera = [_devices objectForKey:device.name];
    [self didRemoveCamera:camera];
    [_devices removeObjectForKey:device.name];
    [camera removeCacheDirectory];
}

-(void)didAddCamera:(OPCamera *)camera
{
    [[_cameraPlugin collections] addObject:camera];
    [[_cameraPlugin delegate] didAddItemCollection:camera];
}

-(void)didRemoveCamera:(OPCamera *)camera
{
    [[_cameraPlugin collections] removeObject:camera];
    [[_cameraPlugin delegate] didRemoveItemCollection:camera];
}


@end
