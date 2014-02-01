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

@interface OPCameraPlugin : NSObject<XPPlugin, XPItemCollectionProvider>

@property (weak, nonatomic) XPCollectionManager *collectionManager;
@property (strong, readonly) OPCameraService *cameraService;
@property (weak) id<XPItemCollectionProviderDelegate> delegate;
@property (strong, readonly) NSMutableSet *collections;
@property (strong) XPBadgeLayer *badgeLayer;
@property (strong) XPBadgeLayer *imageLayer;

@end
