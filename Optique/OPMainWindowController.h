//
//  OPMainWindowController.h
//  Optique
//
//  Created by James Dumay on 26/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPAlbumViewController.h"
#import "OPNavigationControllerDelegate.h"

@interface OPMainWindowController : NSWindowController<NSWindowDelegate, OPNavigationControllerDelegate>

@property (strong, readonly) XPPhotoManager *photoManager;
@property (strong) IBOutlet NSButton *navBackButton;

@property (strong) IBOutlet NSWindow *createAlbumSheetWindow;
@property (strong) IBOutlet NSTextField *albumNameTextField;

-initWithPhotoManager:(XPPhotoManager*)photoManager;

- (IBAction)navigateBack:(id)sender;

-(void)navigateBackward;

-(void)showNewAlbumSheet;

@end
