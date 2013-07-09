//
//  OPPhoto.h
//  Optique
//
//  Created by James Dumay on 21/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XPPhotoCollection;

@protocol XPPhoto

/**
 The photo title
 **/
-(NSString*)title;

-(NSDate*)created;

/**
 The collection (such as the album or camera) that the photo belongs to
 **/
-(id<XPPhotoCollection>) collection;

/**
 Loads the image and returns it via the completion block
 **/
-(void)imageWithCompletionBlock:(XPImageCompletionBlock)completionBlock;

/**
 Loads and scales the image and returns it via the completion block
 May return the full size image if scaling is not available.
 **/
-(void)scaleImageToFitSize:(NSSize)size withCompletionBlock:(XPImageCompletionBlock)completionBlock;

/** 
 Loads the data representing this photo and returns it via the completion block 
 **/
-(NSConditionLock*)resolveURL:(XPURLSupplier)block;

@optional

/**
 Thumbnail provided by implementor
 */
-(NSImage*)thumbnail;

-(NSURL*)url;

-(NSDictionary*)metadata;

@end
