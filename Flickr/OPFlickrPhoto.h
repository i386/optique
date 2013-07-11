//
//  OPFlickrPhoto.h
//  Optique
//
//  Created by James Dumay on 8/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPFlickrPhotoSet.h"

@interface OPFlickrPhoto : NSObject<XPPhoto>

@property (strong) NSURL *url;

-initWithDictionary:(NSDictionary*)dict photoSet:(OPFlickrPhotoSet*)photoSet;

-initWithTitle:(NSString *)title url:(NSURL *)url photoSet:(OPFlickrPhotoSet*)photoSet;

-(void)download;

@end
