//
//  OPImageCollection.h
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPPhoto.h"

@class XPPhotoManager;

typedef NS_ENUM(NSUInteger, XPPhotoCollectionType) {
    kPhotoCollectionLocal,
    kPhotoCollectionCamera,
    kPhotoCollectionOther
};

@protocol XPPhotoCollection <NSObject>

/** the photo manager that the collection belongs to */
-(XPPhotoManager*)photoManager;

/** title of the collection **/
-(NSString*)title;

-(NSDate*)created;

/** all objects conforming to OPPhoto that belong to this collection */
-(NSArray*)allPhotos;

/** all objects filtered by the provided index set conforming to OPPhoto that belong to this collection */
-(NSArray*)photosForIndexSet:(NSIndexSet*)indexSet;

-(id<XPPhoto>)coverPhoto;

/**
 The type of collection that this is (local, camera, other)
 */
-(XPPhotoCollectionType)collectionType;

/**
 Collection exits on local file system
 */
-(BOOL)hasLocalCopy;

@optional

-(NSURL*)path;

/** 
 reloads the content of the collection
 */
-(void)reload;

/** 
 add the provided photo to this collection and call the completion block when done;
 */
-(void)addPhoto:(id<XPPhoto>)photo withCompletion:(XPCompletionBlock)completionBlock;

/**
 delete the photo from this collection and call the completion block when done;
 */
-(void)deletePhoto:(id<XPPhoto>)photo withCompletion:(XPCompletionBlock)completionBlock;

/**
 Metadata that is stored for this Collection so that it can be rebuilt by the album scanner & collection provider on startup
 */
-(NSDictionary*)metadata;

@end
    