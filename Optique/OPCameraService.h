//
//  OPDeviceImageCapture.h
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>
#import "OPCamera.h"

@class OPCameraPlugin;

@interface OPCameraService : NSObject <ICDeviceBrowserDelegate>

@property (readonly, strong) ICDeviceBrowser *deviceBrowser;
@property (weak) OPCameraPlugin *cameraPlugin;

@property (strong) XPPhotoManager *photoManager;

/** all of the available cameras **/
-(NSArray*)allCameras;

/** start listening for devices **/
-(void)start;

/** stop listening for devices **/
-(void)stop;

/** remove all the caches **/
-(void)removeCaches;

-(void)userNeedsToUnlockCamera:(NSString*)message;

@end
