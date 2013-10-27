//
//  OPMainWindowController.h
//  Optique
//
//  Created by James Dumay on 26/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPCollectionViewController.h"

@interface OPMainWindowController : NSWindowController<NSWindowDelegate>

@property (strong, readonly) XPPhotoManager *photoManager;
@property (strong) IBOutlet NSButton *navBackButton;

@property (strong) IBOutlet NSWindow *createAlbumSheetWindow;
@property (strong) IBOutlet NSTextField *albumNameTextField;

-initWithPhotoManager:(XPPhotoManager*)photoManager;

-(void)showNewAlbumSheet;

-(void)goBack;

-(void)showAlbums;

-(void)showCameras;

@end
