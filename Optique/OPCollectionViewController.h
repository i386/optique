//
//  OPAlbumViewController.h
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPCollectionGridView.h"

#import "OPNavigationViewController.h"

@interface OPCollectionViewController : OPNavigationViewController <OEGridViewDelegate, OEGridViewDataSource, NSMenuDelegate, XPCollectionViewController>

@property (weak, readonly) XPCollectionManager *collectionManager;
@property (weak) IBOutlet NSMenu *albumItemContextMenu;
@property (weak) IBOutlet NSMenuItem *deleteAlbumMenuItem;
@property (weak) IBOutlet OPCollectionGridView *gridView;
@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSBox *headingLine;
@property (weak) IBOutlet NSMenuItem *renameAlbumMenuItem;
@property (strong) NSPredicate *predicate;

-(id)initWithCollectionManager:(XPCollectionManager *)collectionManager title:(NSString *)title emptyMessage:(NSString*)emptyMessage icon:(NSImage *)icon collectionPredicate:(NSPredicate *)predicate;

- (IBAction)deleteAlbum:(NSMenuItem*)sender;

- (IBAction)renameAlbum:(id)sender;

- (NSUInteger)numberOfItems;

-(void)showCollectionWithTitle:(NSString*)title;

-(OPNavigationViewController*)viewForCollection:(id<XPItemCollection>)collection collectionManager:(XPCollectionManager*)collectionManager;

@end
