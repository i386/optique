//
//  OPImageCaptureDevice.h
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>

@interface OPCamera : NSObject <XPPhotoCollection, ICCameraDeviceDelegate>

@property (readonly, weak) ICCameraDevice *device;
@property (readonly, weak) XPPhotoManager *photoManager;

-(id)initWithDevice:(ICCameraDevice*)device photoManager:(XPPhotoManager*)photoManager;

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