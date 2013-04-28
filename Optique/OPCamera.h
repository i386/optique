//
//  OPImageCaptureDevice.h
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>
#import "OPPhotoCollection.h"

@interface OPCamera : NSObject <OPPhotoCollection, ICDeviceDelegate>

@property (readonly, strong) ICCameraDevice *device;

-initWithDevice:(ICCameraDevice*)device;

@end
