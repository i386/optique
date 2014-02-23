//
//  XPItem.h
//  Optique
//
//  Created by James Dumay on 4/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSUInteger, XPItemType) {
    /**
     Unknown item
     */
    XPItemTypeUnknown,
    
    /**
     Photo item
     */
    XPItemTypePhoto,
    
    /**
     Video item
     */
    XPItemTypeVideo
};

/**
 Converts UTI type to XPItemType.
 */
XPItemType XPItemTypeFromUTICFString(CFStringRef fileUTI);
XPItemType XPItemTypeFromUTINSString(NSString *fileUTI);

/**
 Finds the XPItemType of a URL
 */
XPItemType XPItemTypeForPath(NSURL *url);

@protocol XPItem;

CGImageRef XPItemGetImageRef(id<XPItem> item, CGSize size);

@protocol XPItemCollection;

/**
 Media item
 */
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
