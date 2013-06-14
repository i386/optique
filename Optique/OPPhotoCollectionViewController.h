//
//  OPPhotoCollectionViewController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationViewController.h"
#import "OPPhotoAlbum.h"
#import "OPGridView.h"

@interface OPPhotoCollectionViewController : OPNavigationViewController <OEGridViewDelegate, OEGridViewDataSource, NSMenuDelegate, XPPhotoCollectionViewController>

@property (strong) IBOutlet NSMenu *contextMenu;
@property (strong) IBOutlet NSMenu *sharingMenu;

@property (strong, readonly) id<XPPhotoCollection> collection;
@property (strong, readonly) XPPhotoManager *photoManager;
@property (strong) IBOutlet OPGridView *gridView;
@property (strong) IBOutlet NSMenuItem *moveToAlbumItem;

-initWithPhotoAlbum:(id<XPPhotoCollection>)collection photoManager:(XPPhotoManager*)photoManager;

- (IBAction)deletePhoto:(id)sender;

@end