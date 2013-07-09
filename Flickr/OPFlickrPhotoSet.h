//
//  OPFlickrPhotoSet.h
//  Optique
//
//  Created by James Dumay on 6/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OPFlickrPhoto;

@interface OPFlickrPhotoSet : NSObject<XPPhotoCollection>

@property (strong, readonly) NSNumber *flickrId;

-initWithDictionary:(NSDictionary*)dict photoManager:(XPPhotoManager*)photoManager;

-(void)setPhotoManager:(XPPhotoManager*)photoManager;

-(void)addPhoto:(OPFlickrPhoto*)photo;

-(NSURL*)path;

@end
