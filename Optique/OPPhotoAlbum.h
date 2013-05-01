//
//  OPPhotoAlbum.h
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OPPhotoCollection.h"
#import "OPImageCache.h"
#import "OPPhoto.h"

@class OPPhotoManager;

@interface OPPhotoAlbum : NSObject <OPPhotoCollection>

@property (strong, readonly) NSString *title;
@property (strong, readonly) NSURL *path;
@property (strong, readonly) OPPhotoManager *photoManager;

-(id)initWithTitle:(NSString *)title path:(NSURL *)path photoManager:(OPPhotoManager*)photoManager;

@end
