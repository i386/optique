//
//  OPPhotoAlbumViewController.h
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "OPPhotoManager.h"
#import "OPPhotoAlbum.h"

@interface OPPhotoAlbumViewController : NSViewController

@property (strong, readonly) OPPhotoManager *photoManager;
@property (strong, readonly) OPPhotoAlbum *photoAlbum;

-initWithPhotoManager:(OPPhotoManager*)photoManager album:(OPPhotoAlbum*)album;

@end
