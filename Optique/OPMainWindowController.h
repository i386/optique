//
//  OPMainWindowController.h
//  Optique
//
//  Created by James Dumay on 26/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPCollectionViewController.h"
#import "OPToolbarViewController.h"

@interface OPMainWindowController : NSWindowController<NSWindowDelegate>

@property (weak, readonly) XPPhotoManager *photoManager;
@property (strong, readonly) OPToolbarViewController *toolbarViewController;

-initWithPhotoManager:(XPPhotoManager*)photoManager;

-(void)showNewAlbumSheet;

-(void)goBack;

-(void)showAlbums;

-(void)showCameras;

@end
