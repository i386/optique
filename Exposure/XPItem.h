//
//  XPItem.h
//  Optique
//
//  Created by James Dumay on 4/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XPPhotoCollection;

@protocol XPItem <NSObject>

/**
 Item title
 */
-(NSString*)title;

@optional

/**
 Collection that the item belongs to. If null, instance can be treated like a collection.
 */
-(id<XPPhotoCollection>)collection;

@end
