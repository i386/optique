//
//  OPBundleLoader.h
//  Optique
//
//  Created by James Dumay on 5/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XPPlugin.h"
#import "XPPhotoCollectionProvider.h"
#import "XPPhotoManager.h"

@interface XPExposureService : NSObject

@property (readonly, strong) NSDictionary *exposures;

+(id<XPPlugin>)pluginForBundle:(NSString*)bundleId;

+(id<XPPhotoCollectionProvider>)photoCollectionProviderForBundle:(NSString*)bundleId;

+(void)loadPlugins:(NSDictionary*)userInfo;

+(void)unloadPlugins:(NSDictionary*)userInfo;

+(void)photoManagerWasCreated:(XPPhotoManager*)photoManager;

+(void)photoManager:(XPPhotoManager*)photoManager collectionViewController:(id<XPCollectionViewController>)controller;

+(void)photoManager:(XPPhotoManager*)photoManager photoCollectionViewController:(id<XPPhotoCollectionViewController>)controller;

+(void)photoManager:(XPPhotoManager*)photoManager photoController:(id<XPPhotoController>)controller;

+(NSSet*)photoCollectionProviders;

+(NSArray*)debugMenuItems;

+(id<XPPhotoCollection>)createCollectionWithTitle:(NSString*)title path:(NSURL*)path;

@end
