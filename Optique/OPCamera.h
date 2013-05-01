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
#import "OPPhotoManager.h"

@interface OPCamera : NSObject <OPPhotoCollection, ICCameraDeviceDelegate>

@property (readonly, strong) ICCameraDevice *device;

-(id)initWithDevice:(ICCameraDevice*)device photoManager:(OPPhotoManager*)photoManager;

-(NSImage*)thumbnailForName:(NSString*)name;

/** 
 Camera cache directory where files downloaded from the camera are stored.
 **/
-(NSURL*)cacheDirectory;

/**
 Remove the cache directory
 **/
-(void)removeCacheDirectory;

-(void)requestEject;

@end
