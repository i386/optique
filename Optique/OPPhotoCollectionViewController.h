//
//  OPPhotoCollectionViewController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationViewController.h"
#import "OPPhotoAlbum.h"
#import "OPPhotoGridView.h"

@interface OPPhotoCollectionViewController : OPNavigationViewController <CNGridViewDataSource, CNGridViewDelegate, NSMenuDelegate, XPPhotoCollectionViewController>

@property (strong) IBOutlet NSMenu *contextMenu;
@property (strong) IBOutlet NSMenu *sharingMenu;

@property (strong, readonly) id<XPPhotoCollection> collection;
@property (strong, readonly) XPPhotoManager *photoManager;
@property (strong) IBOutlet CNGridView *gridView;
@property (strong) IBOutlet NSMenuItem *moveToAlbumItem;

-initWithPhotoAlbum:(id<XPPhotoCollection>)collection photoManager:(XPPhotoManager*)photoManager;

- (IBAction)deletePhoto:(id)sender;

@end