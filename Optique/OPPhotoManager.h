//
//  OPPhotoManager.h
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OPPhotoCollection.h"
#import "OPPhotoAlbum.h"

extern NSString *const OPPhotoManagerDidAddCollection;
extern NSString *const OPPhotoManagerDidUpdateCollection;
extern NSString *const OPPhotoManagerDidDeleteCollection;

@interface OPPhotoManager : NSObject

@property (strong, readonly) NSURL *path;

-initWithPath:(NSURL*)path;

/** all collections (albums, cameras, etc) that are available **/
-(NSArray*)allCollections;

/** filter collections by index set **/
-(NSArray*)allCollectionsForIndexSet:(NSIndexSet*)indexSet;

/** create a new album **/
-(OPPhotoAlbum*)newAlbumWithName:(NSString*)albumName error:(NSError **)error;

/** delete the specified album **/
-(void)deleteAlbum:(OPPhotoAlbum*)photoAlbum;

/** forces the collection to reload and sends a OPPhotoManagerDidUpdateCollection **/
-(void)collectionUpdated:(id<OPPhotoCollection>)album;

@end
