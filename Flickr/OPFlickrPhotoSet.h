//
//  OPFlickrPhotoSet.h
//  Optique
//
//  Created by James Dumay on 6/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Exposure/Exposure.h>

@interface OPFlickrPhotoSet : NSObject<XPPhotoCollection>

-initWithDictionary:(NSDictionary*)dict;

-(void)setPhotoManager:(XPPhotoManager*)photoManager;

@end
