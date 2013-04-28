//
//  OPImageCollection.h
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPPhoto.h"

@class OPPhotoManager;

@protocol OPPhotoCollection <NSObject>

-(OPPhotoManager*)photoManager;

-(NSString*)title;

-(NSArray*)allPhotos;

-(NSArray*)photosForIndexSet:(NSIndexSet*)indexSet;

-(void)reloadPhotos;

@end
