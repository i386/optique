//
//  OPNewAlbumSheetController.h
//  Optique
//
//  Created by James Dumay on 10/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPNavigationController.h"

@interface OPNewAlbumSheetController : NSWindowController

@property (readonly, strong) XPPhotoManager *photoManager;
@property (readonly, weak) OPNavigationController *navigationController;
@property (strong) IBOutlet NSTextField *albumNameTextField;

-initWithPhotoManager:(XPPhotoManager*)photoManager navigationController:(OPNavigationController*)navigationController;

- (IBAction)createAlbum:(id)sender;
- (IBAction)cancel:(id)sender;

@end
