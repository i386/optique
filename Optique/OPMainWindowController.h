//
//  OPMainWindowController.h
//  Optique
//
//  Created by James Dumay on 26/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPAlbumViewController.h"
#import "OPPhotoManager.h"

@interface OPMainWindowController : NSWindowController {
    OPAlbumViewController *_albumViewController;
}

@property (strong) OPPhotoManager *photoManager;

@end
