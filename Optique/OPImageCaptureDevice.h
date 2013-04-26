//
//  OPImageCaptureDevice.h
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>
#import "OPImageCollection.h"

@interface OPImageCaptureDevice : NSObject <OPImageCollection>

@property (readonly, strong) ICDevice *device;

-initWithDevice:(ICDevice*)device;

@end
