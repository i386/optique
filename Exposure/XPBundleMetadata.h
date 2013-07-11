//
//  XPMetadata.h
//  Optique
//
//  Created by James Dumay on 10/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XPBundleMetadata : NSObject

/**
 Creates Exposure metadata at the provided collection path
 @param collectionPath to create meadata for
 @param bundle id of the exposure plugin
 */
+(XPBundleMetadata*)createMetadataForPath:(NSURL*)collectionPath bundleId:(NSString*)bundleId;

/**
 Loads Exposure metadata from a collection path
 @param collectionPath to load metadata from
 */
+(XPBundleMetadata*)metadataForPath:(NSURL*)collectionPath;

@property (readonly, strong) NSString *bundleId;
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
