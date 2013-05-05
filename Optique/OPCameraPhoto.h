//
//  OPCameraFile.h
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>

@interface OPCameraPhoto : NSObject <XPPhoto>

@property (strong) ICCameraFile *cameraFile;
@property (weak) id<XPPhotoCollection> collection;

-(id)initWithCameraFile:(ICCameraFile*)cameraFile collection:(id<XPPhotoCollection>)collection;

-(NSImage*)thumbnail;

@end
