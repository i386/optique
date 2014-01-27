//
//  OPHistoryPeekViewController.h
//  Optique
//
//  Created by James Dumay on 4/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPCollectionGridView.h"
#import "OPItemGridView.h"
#import "OPItemGridViewCell.h"
#import "OPNavigationController.h"

@interface OPHistoryPeekViewController : NSViewController<OEGridViewDelegate, OEGridViewDataSource, NSPopoverDelegate>

@property (strong) OPGridView *gridView;
@property (strong) IBOutlet OPCollectionGridView *collectionGridView;
@property (strong) IBOutlet OPItemGridView *itemGridView;
@property (strong) NSArray *items;
@property (weak) OPNavigationController *navigationController;
@property (strong) IBOutlet NSPopover *popover;
@property (strong) IBOutlet NSViewController *popoverViewController;

-initWithItems:(NSArray*)items navigationController:(OPNavigationController*)navigationController;

-(bool)showable;

@end
