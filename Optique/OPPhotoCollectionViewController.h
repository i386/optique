//
//  OPPhotoCollectionViewController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationViewController.h"
#import "OPPhotoGridView.h"
#import "OPPhotoGridViewCell.h"
#import <KBButton/KBButton.h>

@interface OPPhotoCollectionViewController : OPNavigationViewController <OEGridViewDelegate, OEGridViewDataSource, NSMenuDelegate, XPPhotoCollectionViewController>

@property (strong) IBOutlet NSMenu *contextMenu;
@property (strong) IBOutlet NSMenu *sharingMenu;

@property (strong, readonly) id<XPPhotoCollection> collection;
@property (strong, readonly) XPPhotoManager *photoManager;
@property (strong) IBOutlet OPPhotoGridView *gridView;
@property (strong) IBOutlet NSMenuItem *moveToAlbumItem;
@property (weak) IBOutlet NSBox *headingLine;
@property (weak) IBOutlet NSTextField *dateLabel;
@property (weak) IBOutlet KBButton *primaryActionButton;
@property (weak) IBOutlet KBButton *secondaryActionButton;

-initWithPhotoAlbum:(id<XPPhotoCollection>)collection photoManager:(XPPhotoManager*)photoManager;

- (IBAction)deletePhoto:(id)sender;

//TODO: move the items below and use a delegate

- (IBAction)primaryActionActivated:(id)sender;

- (IBAction)secondaryActionActivated:(id)sender;

-(OPPhotoGridViewCell*)createPhotoGridViewCell;

@end