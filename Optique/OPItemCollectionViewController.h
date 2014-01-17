//
//  OPPhotoCollectionViewController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationViewController.h"
#import "OPItemGridView.h"
#import "OPItemGridViewCell.h"
#import <KBButton/KBButton.h>

@interface OPItemCollectionViewController : OPNavigationViewController <OEGridViewDelegate, OEGridViewDataSource, NSMenuDelegate, XPItemCollectionViewController>

@property (weak) IBOutlet NSMenu *contextMenu;
@property (weak) IBOutlet NSMenu *sharingMenu;

@property (weak, readonly) id<XPItemCollection> collection;
@property (weak, readonly) XPCollectionManager *collectionManager;
@property (weak) IBOutlet OPItemGridView *gridView;
@property (weak) IBOutlet NSMenuItem *moveToAlbumItem;
@property (weak) IBOutlet NSBox *headingLine;
@property (weak) IBOutlet NSTextField *dateLabel;
@property (weak) IBOutlet KBButton *primaryActionButton;
@property (weak) IBOutlet KBButton *secondaryActionButton;

-initWithPhotoAlbum:(id<XPItemCollection>)collection collectionManager:(XPCollectionManager*)collectionManager;

- (IBAction)deletePhoto:(id)sender;

//TODO: move the items below and use a delegate

- (IBAction)primaryActionActivated:(id)sender;

- (IBAction)secondaryActionActivated:(id)sender;

-(OPItemGridViewCell*)createPhotoGridViewCell;

@end