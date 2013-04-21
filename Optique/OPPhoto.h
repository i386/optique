//
//  OPPhoto.h
//  Optique
//
//  Created by James Dumay on 21/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OPPhotoAlbum;

@interface OPPhoto : NSObject

@property (strong, readonly) NSString *title;
@property (strong, readonly) NSURL *path;
@property (strong, readonly) OPPhotoAlbum *album;

-(id)initWithTitle:(NSString *)title path:(NSURL *)path album:(OPPhotoAlbum*)album;

-(NSImage*)image;

-(NSImage*)scaleImageToFitSize:(NSSize)size;

@end
