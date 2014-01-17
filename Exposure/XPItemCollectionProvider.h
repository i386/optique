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
#import "XPItemCollection.h"
#import "XPItem.h"
#import "XPItemCollectionProviderDelegate.h"
#import "XPBadgeLayer.h"

@protocol XPItemCollectionProvider <XPPlugin>

@property (weak) id<XPItemCollectionProviderDelegate> delegate;

/**
 PhotoCollections that belong to this provider
 */
-(NSSet*)collections;

@optional

/**
 Create collection at path
 */
-(id<XPItemCollection>)createCollectionAtPath:(NSURL *)url metadata:(NSDictionary*)metadata collectionManager:(XPCollectionManager*)collectionManager;

/**
 Layer to add to the cell of the collection
 */
-(XPBadgeLayer*)badgeLayerForCollection:(id<XPItemCollection>)collection;

/**
 Layer to add to the cell of the item
 */
-(XPBadgeLayer*)badgeLayerForPhoto:(id<XPItem>)item;

@end
