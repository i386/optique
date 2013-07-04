//
//  OPPhotoAlbum.h
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OPImageCache.h"

@class XPPhotoManager;

@interface OPPhotoAlbum : NSObject <XPPhotoCollection>

@property (strong, readonly) NSString *title;
@property (strong, readonly) NSDate *created;
@property (strong, readonly) NSURL *path;
@property (strong, readonly) XPPhotoManager *photoManager;

-(id)initWithTitle:(NSString *)title path:(NSURL *)path photoManager:(XPPhotoManager*)photoManager;

@end
