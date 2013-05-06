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

+(void)collectionViewController:(id<XPCollectionViewController>)controller;

+(void)photoCollectionViewController:(id<XPPhotoCollectionViewController>)controller;

+(void)photoViewController:(id<XPPhotoViewController>)controller;

@end
