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
    /**
     Local file stem collection
     */
    XPItemCollectionLocal,
    
    /**
     Collection is a camera
     */
    XPItemCollectionCamera,
    
    /**
     Collection is something else, perhaps defined by a Exposure.
     */
    XPItemCollectionOther
};

@protocol XPItemCollection <NSObject>

/** 
 Collection manager that the collection belongs to
 */
@property (readonly) XPCollectionManager *collectionManager;

/** 
 Title of the collection
 **/
@property (readonly) NSString *title;

/**
 Creation date
 */
@property (readonly) NSDate *created;

/** all objects conforming to OPPhoto that belong to this collection */
-(NSOrderedSet*)allItems;

/** all objects filtered by the provided index set conforming to OPPhoto that belong to this collection */
-(NSArray*)itemsAtIndexes:(NSIndexSet*)indexSet;

/**
 Item to be used as the cover of the collection
 */
@property (readonly) id<XPItem> coverItem;

/**
 The type of collection that this is (local, camera, other)
 */
@property (readonly) XPItemCollectionType collectionType;

/**
 Exists on the file system
 */
@property (readonly) BOOL hasLocalCopy;

@optional

/**
 Thumbnail image, if available
 */
@property (readonly) NSImage *thumbnail;

/**
 Path of collection of file system
 */
@property (readonly) NSURL *path;

/**
 Metadata that is stored for this Collection so that it can be rebuilt by the album scanner & collection provider on startup
 */
@property (readonly) NSDictionary *metadata;

/** 
 Reload collection
 */
-(void)reload;

/** 
 Move the provided item to this collection and call the completion block when done;
 */
-(void)moveItem:(id<XPItem>)item withCompletion:(XPCompletionBlock)completionBlock;

/**
 Copy the provided item to this collection and call the completion block when done;
 */
-(void)copyItem:(id<XPItem>)item withCompletion:(XPCompletionBlock)completionBlock;

/**
 Delete the item from this collection and call the completion block when done;
 */
-(void)deleteItem:(id<XPItem>)item withCompletion:(XPCompletionBlock)completionBlock;

@end
    