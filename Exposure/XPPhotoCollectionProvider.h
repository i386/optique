//
//  OPPhotoCollectionProvider.h
//  Optique
//
//  Created by James Dumay on 5/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "XPPlugin.h"
#import "XPPhotoCollection.h"
#import "XPPhotoCollectionProviderDelegate.h"
#import "XPBadgeLayer.h"

@protocol XPPhotoCollectionProvider <XPPlugin>

@property (weak) id<XPPhotoCollectionProviderDelegate> delegate;

/**
 PhotoCollections that belong to this provider
 */
-(NSArray*)photoCollections;

@optional

/**
 Create collection at path
 */
-(id<XPPhotoCollection>)createCollectionAtPath:(NSURL *)url metadata:(NSDictionary*)metadata photoManager:(XPPhotoManager*)photoManager;

/**
 Layer to add to the grid item of the collection
 */
-(XPBadgeLayer*)badgeLayerForCollection:(id<XPPhotoCollection>)collection;

@end
