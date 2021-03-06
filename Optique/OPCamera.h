//
//  OPImageCaptureDevice.h
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>
#import <Exposure/Exposure.h>

@class OPCameraService;

@interface OPCamera : NSObject <XPItemCollection, ICCameraDeviceDelegate>

@property (readonly, weak) ICCameraDevice *device;
@property (readonly, weak) XPCollectionManager *collectionManager;
@property (readonly, strong) NSDate *created;
@property (readonly, assign) NSString *title;

-(id)initWithDevice:(ICCameraDevice*)device collectionManager:(XPCollectionManager*)collectionManager service:(OPCameraService*)service;

@property (assign, nonatomic, getter = isDefaultApp) BOOL defaultApp;

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

-(BOOL)isLocked;

@end
