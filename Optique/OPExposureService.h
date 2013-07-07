//
//  OPBundleLoader.h
//  Optique
//
//  Created by James Dumay on 5/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPExposureService : NSObject

@property (readonly, strong) NSDictionary *exposures;

+(void)photoManager:(XPPhotoManager*)photoManager collectionViewController:(id<XPCollectionViewController>)controller;

+(void)photoManager:(XPPhotoManager*)photoManager photoCollectionViewController:(id<XPPhotoCollectionViewController>)controller;

+(void)photoManager:(XPPhotoManager*)photoManager photoController:(id<XPPhotoController>)controller;

+(NSSet*)photoCollectionProviders;

+(NSArray*)debugMenuItems;

@end
