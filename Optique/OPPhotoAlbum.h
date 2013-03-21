//
//  OPPhotoAlbum.h
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPPhotoAlbum : NSObject

@property (assign, readonly) NSString *name;
@property (assign, readonly) NSURL *path;

-initWithName:(NSString*)name path:(NSURL*)path;

@end
