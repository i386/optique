//
//  OPCameraPlugin.h
//  Optique
//
//  Created by James Dumay on 7/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Exposure/Exposure.h>

#import "OPCameraService.h"

@interface OPCameraPlugin : NSObject<XPPlugin, XPPhotoCollectionProvider>

@property (strong, readonly) OPCameraService *cameraService;
@property (weak) id<XPPhotoCollectionProviderDelegate> delegate;
@property (strong, readonly) NSMutableArray *photoCollections;

@end
