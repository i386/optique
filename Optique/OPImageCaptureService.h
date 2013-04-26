//
//  OPDeviceImageCapture.h
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>

@interface OPImageCaptureService : NSObject <ICDeviceBrowserDelegate, ICCameraDeviceDelegate>

@property (readonly, strong) ICDeviceBrowser *deviceBrowser;

/** restart the image capture service **/
-(void)restart;

@end
