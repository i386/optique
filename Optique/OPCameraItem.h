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

@interface OPCameraItem : NSObject <XPItem, ICCameraDeviceDownloadDelegate>

@property (strong) ICCameraFile *cameraFile;
@property (weak) id<XPItemCollection> collection;
@property (strong) NSURL *path;
@property (assign) XPItemType type;

-(id)initWithCameraFile:(ICCameraFile*)cameraFile collection:(id<XPItemCollection>)collection type:(XPItemType)type;

-(NSImage*)thumbnail;

@end
