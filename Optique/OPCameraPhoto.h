//
//  OPCameraFile.h
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>
#import "OPPhoto.h"

@interface OPCameraPhoto : NSObject <OPPhoto>

-(id)initWithCameraFile:(ICCameraFile*)cameraFile collection:(id<OPPhotoCollection>)collection;

-(NSImage*)thumbnail;

@end
