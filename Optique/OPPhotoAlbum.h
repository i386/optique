//
//  OPPhotoAlbum.h
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPImageCache.h"

@interface OPPhotoAlbum : NSObject

@property (strong, readonly) NSString *title;
@property (strong, readonly) NSURL *path;

-initWithTitle:(NSString*)title path:(NSURL*)path;

-(NSArray*)allPhotos;

-(void)reloadPhotos;

@end
