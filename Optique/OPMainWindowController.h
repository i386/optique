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
#import "XPSidebarController.h"
#import "OPSplitView.h"

@interface OPMainWindowController : NSWindowController<NSWindowDelegate, XPSidebarController, NSSplitViewDelegate>

@property (weak, readonly) XPCollectionManager *collectionManager;
@property (weak, readwrite) IBOutlet OPToolbarController *toolbarViewController;
@property (weak) IBOutlet OPSplitView *splitView;
@property (weak) IBOutlet NSView *leftSplitView;
@property (weak) IBOutlet NSView *rightSplitView;
@property (weak) IBOutlet NSToolbar *toolbar;

-initWithCollectionManager:(XPCollectionManager*)collectionManager;

-(void)goBack;

-(void)showAlbums;

-(void)showCameras;

@end
