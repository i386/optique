//
//  OPDeviceImageCapture.h
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>

NSString *const OPCameraServiceDidAddCamera;
NSString *const OPCameraServiceDidRemoveCamera;

@interface OPCameraService : NSObject <ICDeviceBrowserDelegate>

@property (readonly, strong) ICDeviceBrowser *deviceBrowser;

/** restart the image capture service **/
-(void)restart;

@end
