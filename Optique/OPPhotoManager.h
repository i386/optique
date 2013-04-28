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

-(NSArray*)allCollections;

-(NSArray*)allCollectionsForIndexSet:(NSIndexSet*)indexSet;

-(OPPhotoAlbum*)newAlbumWithName:(NSString*)albumName error:(NSError **)error;

-(void)deleteAlbum:(OPPhotoAlbum*)photoAlbum;

-(void)collectionUpdated:(id<OPPhotoCollection>)album;

@end
