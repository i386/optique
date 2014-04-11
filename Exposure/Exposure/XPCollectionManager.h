//
//  XPCollectionManager.h
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XPItemCollection.h"
#import "XPItemCollectionProviderDelegate.h"

extern NSString *const XPCollectionManagerDidAddCollection;
extern NSString *const XPCollectionManagerDidUpdateCollection;
extern NSString *const XPCollectionManagerDidDeleteCollection;

@interface XPCollectionManager : NSObject<XPItemCollectionProviderDelegate>

@property (strong, readonly) NSURL *path;

/**
 All collections (albums, cameras, etc) that are available
 */
@property (readonly, nonatomic) NSArray *allCollections;

/**
 All items across every collection
 */
@property (readonly, nonatomic) NSEnumerator *allItems;

-initWithPath:(NSURL*)path;

/** 
 Filter collections by index set 
 */
-(NSArray*)allCollectionsForIndexSet:(NSIndexSet*)indexSet;

/** 
 Create a new album 
 */
-(id<XPItemCollection>)newAlbumWithName:(NSString*)albumName error:(NSError *__autoreleasing *)error;

/**
 Delete the specified album
 */
-(void)deleteAlbum:(id<XPItemCollection>)collection error:(NSError *__autoreleasing *)error;

/**
 Rename the specified album
 */
-(void)renameAlbum:(id<XPItemCollection>)collection to:(NSString*)name error:(NSError *__autoreleasing *)error;

/**
 Create new album on the file system using a non-local item collection prototype and a bundle identifier. Not recommended to be called directly.
 */
-(id<XPItemCollection>)createLocalPhotoCollectionWithPrototype:(id<XPItemCollection>)prototype identifier:(NSString *)exposureId error:(NSError *__autoreleasing *)error;

/** 
 Forces the collection to reload and sends a XPCollectionManagerDidUpdateCollection 
 */
-(void)collectionUpdated:(id<XPItemCollection>)collection reload:(BOOL)shouldReload;

@end
