//
//  OPImageCollection.h
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPItem.h"

extern NSString *const XPItemCollectionDidStartLoading;
extern NSString *const XPItemCollectionDidStopLoading;

@class XPCollectionManager;

typedef NS_ENUM(NSUInteger, XPItemCollectionType) {
    XPItemCollectionLocal,
    XPItemCollectionCamera,
    XPItemCollectionOther
};

@protocol XPItemCollection <NSObject>

/** the photo manager that the collection belongs to */
-(XPCollectionManager*)collectionManager;

/** title of the collection **/
-(NSString*)title;

-(NSDate*)created;

/** all objects conforming to OPPhoto that belong to this collection */
-(NSOrderedSet*)allItems;

/** all objects filtered by the provided index set conforming to OPPhoto that belong to this collection */
-(NSArray*)itemsAtIndexes:(NSIndexSet*)indexSet;

-(id<XPItem>)coverItem;

/**
 The type of collection that this is (local, camera, other)
 */
-(XPItemCollectionType)collectionType;

/**
 Collection exists on local file system
 */
-(BOOL)hasLocalCopy;

@optional

-(NSImage*)thumbnail;

-(NSURL*)path;

/** 
 reloads the content of the collection
 */
-(void)reload;

/** 
 move the provided item to this collection and call the completion block when done;
 */
-(void)moveItem:(id<XPItem>)item withCompletion:(XPCompletionBlock)completionBlock;

/**
 copy the provided item to this collection and call the completion block when done;
 */
-(void)copyItem:(id<XPItem>)item withCompletion:(XPCompletionBlock)completionBlock;


/**
 delete the item from this collection and call the completion block when done;
 */
-(void)deleteItem:(id<XPItem>)item withCompletion:(XPCompletionBlock)completionBlock;

/**
 Metadata that is stored for this Collection so that it can be rebuilt by the album scanner & collection provider on startup
 */
-(NSDictionary*)metadata;

@end
    