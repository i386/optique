//
//  OPDeviceImageCapture.m
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImageCaptureService.h"
#import "OPImageCaptureDevice.h"

@interface OPImageCaptureService() {
    NSMutableDictionary *_devices;
}

@end

@implementation OPImageCaptureService

-(id)init
{
    self = [super init];
    if (self)
    {
        _devices = [NSMutableDictionary dictionary];
        _deviceBrowser = [[ICDeviceBrowser alloc] init];
        _deviceBrowser.delegate = self;
        _deviceBrowser.browsedDeviceTypeMask = _deviceBrowser.browsedDeviceTypeMask | ICDeviceTypeMaskCamera | ICDeviceLocationTypeMaskLocal | ICDeviceLocationTypeMaskShared | ICDeviceLocationTypeMaskBonjour | ICDeviceLocationTypeMaskBluetooth | ICDeviceLocationTypeMaskRemote;
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
    OPImageCaptureDevice *imageCaptureDevice = [[OPImageCaptureDevice alloc] initWithDevice:device];
    [_devices setObject:imageCaptureDevice forKey:device.name];
}

-(void)deviceBrowser:(ICDeviceBrowser *)browser didRemoveDevice:(ICDevice *)device moreGoing:(BOOL)moreGoing
{
    [_devices removeObjectForKey:device.name];
}

@end
