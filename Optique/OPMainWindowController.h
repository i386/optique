//
//  OPMainWindowController.h
//  Optique
//
//  Created by James Dumay on 26/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPCollectionViewController.h"
#import "OPToolbarController.h"
#import "OPWindowSidebar.h"

@interface OPMainWindowController : NSWindowController<NSWindowDelegate, OPWindowSidebar>

@property (weak, readonly) XPPhotoManager *photoManager;
@property (weak, readwrite) IBOutlet OPToolbarController *toolbarViewController;
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSView *leftSplitView;
@property (weak) IBOutlet NSView *rightSplitView;

-initWithPhotoManager:(XPPhotoManager*)photoManager;

-(void)goBack;

-(void)showAlbums;

-(void)showCameras;

@end
