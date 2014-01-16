//
//  OPCameraFile.h
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>
#import <Exposure/Exposure.h>

@interface OPCameraPhoto : NSObject <XPPhoto, ICCameraDeviceDownloadDelegate>

@property (strong) ICCameraFile *cameraFile;
@property (weak) id<XPPhotoCollection> collection;
@property (strong) NSURL *path;
@property (assign) XPPhotoType type;

-(id)initWithCameraFile:(ICCameraFile*)cameraFile collection:(id<XPPhotoCollection>)collection type:(XPPhotoType)type;

-(NSImage*)thumbnail;

@end
