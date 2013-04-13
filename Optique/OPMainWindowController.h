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

@interface OPMainWindowController : NSWindowController<NSWindowDelegate>

@property (strong, readonly) OPPhotoManager *photoManager;

@property (strong) IBOutlet NSWindow *createAlbumSheetWindow;
@property (strong) IBOutlet NSTextField *albumNameTextField;

-initWithPhotoManager:(OPPhotoManager*)photoManager;

-(void)showNewAlbumSheet;

@end
