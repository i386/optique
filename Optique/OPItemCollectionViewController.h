//
//  OPPhotoCollectionViewController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPItemGridView.h"
#import "OPItemGridViewCell.h"
#import "OPLineBox.h"

@interface OPItemCollectionViewController : NSViewController <XPNavigationViewController, OEGridViewDelegate, OEGridViewDataSource, NSMenuDelegate, XPItemCollectionViewController>

@property (assign) id<XPNavigationController> controller;
@property (weak) IBOutlet NSMenu *contextMenu;
@property (weak) IBOutlet NSMenu *sharingMenu;

@property (weak, readonly) id<XPItemCollection> collection;
@property (weak, readonly) XPCollectionManager *collectionManager;
@property (weak) IBOutlet OPItemGridView *gridView;
@property (weak) IBOutlet NSMenuItem *moveToAlbumItem;
@property (weak) IBOutlet OPLineBox *headingLine;
@property (weak) IBOutlet NSTextField *dateLabel;
@property (weak) IBOutlet NSButton *primaryActionButton;
@property (weak) IBOutlet NSButton *secondaryActionButton;

-initWithIemCollection:(id<XPItemCollection>)collection collectionManager:(XPCollectionManager*)collectionManager;

- (IBAction)deleteItem:(id)sender;

//TODO: move the items below and use a delegate

- (IBAction)primaryActionActivated:(id)sender;

- (IBAction)secondaryActionActivated:(id)sender;

-(OPItemGridViewCell*)createItemGridViewCell:(id<XPItem>)item;

@end