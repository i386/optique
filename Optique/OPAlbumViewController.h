//
//  OPAlbumViewController.h
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPGridView.h"

#import "OPNavigationViewController.h"

@interface OPAlbumViewController : OPNavigationViewController <OEGridViewDelegate, OEGridViewDataSource, NSMenuDelegate, XPCollectionViewController>

@property (strong) IBOutlet NSMenu *albumItemContextMenu;
@property (strong, readonly) XPPhotoManager *photoManager;
@property (strong) IBOutlet NSMenuItem *deleteAlbumMenuItem;
@property (strong) IBOutlet NSMenuItem *ejectMenuItem;
@property (strong) IBOutlet OPGridView *gridView;

-initWithPhotoManager:(XPPhotoManager*)photoManager;

- (IBAction)deleteAlbum:(NSMenuItem*)sender;

@end
