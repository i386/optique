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

@property (readonly, strong) XPCollectionManager *collectionManager;
@property (readonly, weak) OPNavigationController *navigationController;
@property (weak) IBOutlet NSTextField *albumNameTextField;

-initWithCollectionManager:(XPCollectionManager*)collectionManager navigationController:(OPNavigationController*)navigationController;

- (IBAction)createAlbum:(id)sender;
- (IBAction)cancel:(id)sender;

@end
