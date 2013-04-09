//
//  OPPhotoManager.h
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OPPhotoAlbum.h"

NSString *const OPPhotoManagerDidAddAlbum;
NSString *const OPPhotoManagerDidUpdateAlbum;

@interface OPPhotoManager : NSObject

@property (strong, readonly) NSURL *path;
@property (strong, readonly) NSArray *allAlbums;

-initWithPath:(NSURL*)path;

@end
