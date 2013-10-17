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

@interface OPCollectionViewController : OPNavigationViewController <OEGridViewDelegate, OEGridViewDataSource, NSMenuDelegate, XPCollectionViewController>

@property (strong, readonly) XPPhotoManager *photoManager;
@property (strong) IBOutlet NSMenu *albumItemContextMenu;
@property (strong) IBOutlet NSMenuItem *deleteAlbumMenuItem;
@property (strong) IBOutlet OPGridView *gridView;
@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSBox *headingLine;

-(id)initWithPhotoManager:(XPPhotoManager *)photoManager title:(NSString *)title emptyMessage:(NSString*)emptyMessage icon:(NSImage *)icon collectionPredicate:(NSPredicate *)predicate;

- (IBAction)deleteAlbum:(NSMenuItem*)sender;

- (NSUInteger)numberOfItems;

-(void)showCollectionWithTitle:(NSString*)title;

@end
