//
//  OPPhotoCollectionViewController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationViewController.h"
#import "OPPhotoManager.h"
#import "OPPhotoAlbum.h"
#import "OPPhotoGridView.h"

@interface OPPhotoCollectionViewController : OPNavigationViewController <CNGridViewDataSource, CNGridViewDelegate, NSMenuDelegate>

@property (strong) IBOutlet NSMenu *photoItemContextMenu;
@property (strong) IBOutlet NSMenu *contextMenu;

@property (strong, readonly) OPPhotoAlbum *photoAlbum;
@property (strong, readonly) OPPhotoManager *photoManager;
@property (strong) IBOutlet CNGridView *gridView;
@property (strong) IBOutlet NSMenuItem *moveToAlbumItem;

-initWithPhotoAlbum:(OPPhotoAlbum*)photoAlbum photoManager:(OPPhotoManager*)photoManager;

- (IBAction)revealInFinder:(NSMenuItem*)sender;
- (IBAction)deletePhoto:(id)sender;

@end
