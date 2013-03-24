//
//  OPPhotoManager.h
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OPPhotoAlbum.h"

@interface OPPhotoManager : NSObject

@property (strong, readonly) NSURL *path;

-initWithPath:(NSURL*)path;

-(NSArray*)allAlbums;

@end
