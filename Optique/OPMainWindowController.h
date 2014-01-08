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
#import "OPWindowSidebarController.h"
#import "OPSplitView.h"

@interface OPMainWindowController : NSWindowController<NSWindowDelegate, OPWindowSidebarController, NSSplitViewDelegate>

@property (weak, readonly) XPPhotoManager *photoManager;
@property (weak, readwrite) IBOutlet OPToolbarController *toolbarViewController;
@property (weak) IBOutlet OPSplitView *splitView;
@property (weak) IBOutlet NSView *leftSplitView;
@property (weak) IBOutlet NSView *rightSplitView;

-initWithPhotoManager:(XPPhotoManager*)photoManager;

-(void)goBack;

-(void)showAlbums;

-(void)showCameras;

@end
