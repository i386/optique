//
//  XPMetadata.h
//  Optique
//
//  Created by James Dumay on 10/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XPMetadata : NSObject

+(XPMetadata*)createMetadataForPath:(NSURL*)collectionPath bundleId:(NSString*)bundleId;

+(XPMetadata*)metadataForPath:(NSURL*)collectionPath;

@property (readonly, strong) NSString *bundleId;
@property (readonly, strong) NSMutableDictionary *bundleData;

-(void)write;

@end
