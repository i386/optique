//
//  OPAlbumViewController.h
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CNGridView/CNGridView.h>

#import "OPEffectCollectionView.h"
#import "OPNavigationViewController.h"

@interface OPAlbumViewController : OPNavigationViewController <CNGridViewDataSource, CNGridViewDelegate, NSMenuDelegate>

@property (strong) IBOutlet NSMenu *albumItemContextMenu;
@property (strong, readonly) XPPhotoManager *photoManager;
@property (strong) IBOutlet CNGridView *gridView;
@property (strong) IBOutlet NSMenuItem *revealInFinderMenuItem;
@property (strong) IBOutlet NSMenuItem *deleteAlbumMenuItem;
@property (strong) IBOutlet NSMenuItem *ejectMenuItem;

-initWithPhotoManager:(XPPhotoManager*)photoManager;

- (IBAction)revealInFinder:(NSMenuItem*)sender;

- (IBAction)deleteAlbum:(NSMenuItem*)sender;

- (IBAction)ejectCamera:(id)sender;

@end
