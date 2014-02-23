//
//  XPMetadata.h
//  Optique
//
//  Created by James Dumay on 10/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Utility for loading .optique metadata files
 */
@interface XPBundleMetadata : NSObject

/**
 Creates Exposure metadata at the provided collection path
 @param collectionPath to create meadata for
 @param bundleId of the exposure plugin
 */
+(XPBundleMetadata*)createMetadataForPath:(NSURL*)collectionPath bundleId:(NSString*)bundleId;

/**
 Loads Exposure metadata from a collection path
 @param collectionPath to load metadata from
 */
+(XPBundleMetadata*)metadataForPath:(NSURL*)collectionPath;

/**
 Bundle identifier for the Exposure plugin that wrote the metadata
 */
@property (readonly, strong) NSString *bundleId;

/**
 Bundle data private to the exposure plugin represented by the bundleId
 */
@property (readonly, strong) NSMutableDictionary *bundleData;

/**
 Write the current bundleData to disk
 */
-(void)write;

/**
 Reload the bundleData from disk
 */
-(void)reload;

@end
