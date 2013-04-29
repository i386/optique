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

/** the photo manager that the collection belongs to **/
-(OPPhotoManager*)photoManager;

/** title of the collection **/
-(NSString*)title;

/** all objects conforming to OPPhoto that belong to this collection **/
-(NSArray*)allPhotos;

/** all objects filtered by the provided index set conforming to OPPhoto that belong to this collection **/
-(NSArray*)photosForIndexSet:(NSIndexSet*)indexSet;

/** reloads the content of the collection **/
-(void)reload;

@end
    