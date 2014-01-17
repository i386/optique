//
//  XPItem.h
//  Optique
//
//  Created by James Dumay on 4/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, XPItemType) {
    XPItemTypeUnknown,
    XPItemTypePhoto,
    XPItemTypeVideo
};

/**
 Converts UTI type to XPItemType.
 */
XPItemType XPItemTypeFromUTICFString(CFStringRef fileUTI);
XPItemType XPItemTypeFromUTINSString(NSString *fileUTI);

@protocol XPItemCollection;

@protocol XPItem <NSObject>

/**
 The photo title
 */
-(NSString*)title;

/**
 When the photo was created
 */
-(NSDate*)created;

/**
 The collection (such as the album or camera) that the photo belongs to
 */
-(id<XPItemCollection>) collection;

/**
 Loads and scales the image and returns it via the completion block
 May return the full size image if scaling is not available.
 */
-(void)scaleImageToFitSize:(NSSize)size withCompletionBlock:(XPImageCompletionBlock)completionBlock;

/**
 URL to the photo, if available.
 */
-(NSURL*)url;

/**
 URL exits on local file system
 */
-(BOOL)hasLocalCopy;

/**
 Type of item
 */
-(XPItemType)type;

@optional

/**
 Thumbnail image, if available
 */
-(NSImage*)thumbnail;

/**
 Fetches the local copy
 */
-(void)requestLocalCopy:(NSURL*)directory whenDone:(XPCompletionBlock)callback;

-(void)requestLocalCopyInCacheWhenDone:(XPCompletionBlock)callback;

/**
 Metadata that is stored for this Photo so that it can be rebuilt by the album scanner & collection provider on startup
 */
-(NSDictionary*)metadata;

@end
