//
//  XPItem.h
//  Optique
//
//  Created by James Dumay on 4/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

extern NSString *const XPItemWillReload;

@protocol XPItem;

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

/**
 Creates a CGImageRef for a XPItem
 */
CGImageRef XPItemGetImageRef(id<XPItem> item, CGSize size);

@protocol XPItemCollection;

/**
 Media item
 */
@protocol XPItem <NSObject>

/**
 The photo title
 */
@property (readonly) NSString *title;

/**
 When the photo was created
 */
@property (readonly) NSDate *created;

/**
 The collection (such as the album or camera) that the photo belongs to
 */
@property (readonly, weak) id<XPItemCollection> collection;

/**
 URL to the photo, if available.
 */
@property (readonly) NSURL *url;

/**
 URL exits on local file system
 */
@property (readonly) BOOL hasLocalCopy;

/**
 Type of item
 */
@property (readonly) XPItemType type;

@optional

/**
 Thumbnail image, if available
 */
@property (readonly) NSImage *thumbnail;

/**
 Metadata that is stored for this Photo so that it can be rebuilt by the album scanner & collection provider on startup
 */
@property (readonly) NSDictionary *metadata;

/**
 Fetches the local copy
 */
-(void)requestLocalCopy:(NSURL*)directory whenDone:(XPCompletionBlock)callback;

-(void)requestLocalCopyInCacheWhenDone:(XPCompletionBlock)callback;

@end
