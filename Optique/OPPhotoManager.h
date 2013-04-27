//
//  OPPhotoManager.h
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OPImageCollection.h"
#import "OPPhotoAlbum.h"

NSString *const OPPhotoManagerDidAddAlbum;
NSString *const OPPhotoManagerDidUpdateAlbum;
NSString *const OPPhotoManagerDidDeleteAlbum;

@interface OPPhotoManager : NSObject

@property (strong, readonly) NSURL *path;

-initWithPath:(NSURL*)path;

-(NSArray*)allCollections;

-(NSArray*)allCollectionsForIndexSet:(NSIndexSet*)indexSet;

-(OPPhotoAlbum*)newAlbumWithName:(NSString*)albumName error:(NSError **)error;

-(void)deleteAlbum:(OPPhotoAlbum*)photoAlbum;

-(void)collectionUpdated:(id<OPPhotoCollection>)album;

@end
