//
//  XPPhotoManager.h
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XPPhotoCollection.h"
#import "XPPhotoCollectionProviderDelegate.h"

extern NSString *const XPPhotoManagerDidAddCollection;
extern NSString *const XPPhotoManagerDidUpdateCollection;
extern NSString *const XPPhotoManagerDidDeleteCollection;

@interface XPPhotoManager : NSObject<XPPhotoCollectionProviderDelegate>

@property (strong, readonly) NSURL *path;

-initWithPath:(NSURL*)path;

/** all collections (albums, cameras, etc) that are available **/
-(NSArray*)allCollections;

/** filter collections by index set **/
-(NSArray*)allCollectionsForIndexSet:(NSIndexSet*)indexSet;

/** create a new album **/
-(id<XPPhotoCollection>)newAlbumWithName:(NSString*)albumName error:(NSError **)error;

/**
 Create new album using a bundle identifier. Not recommended to be called directly.
 */
-(id<XPPhotoCollection>)createLocalPhotoCollectionWithPrototype:(id<XPPhotoCollection>)prototype identifier:(NSString *)exposureId error:(NSError *__autoreleasing *)error;

/** delete the specified album **/
-(void)deleteAlbum:(id<XPPhotoCollection>)collection;

/** forces the collection to reload and sends a XPPhotoManagerDidUpdateCollection **/
-(void)collectionUpdated:(id<XPPhotoCollection>)collection;

@end
