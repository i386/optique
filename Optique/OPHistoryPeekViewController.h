//
//  OPHistoryPeekViewController.h
//  Optique
//
//  Created by James Dumay on 4/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPGridView.h"
#import "OPPhotoGridView.h"
#import "OPPhotoGridViewCell.h"
#import "OPNavigationController.h"

@interface OPHistoryPeekViewController : NSViewController<OEGridViewDelegate, OEGridViewDataSource>

@property (weak) OEGridView *gridView;
@property (strong) IBOutlet OPGridView *collectionGridView;
@property (strong) IBOutlet OPPhotoGridView *photoGridView;
@property (strong) NSArray *items;
@property (weak) OPNavigationController *navigationController;

-initWithItems:(NSArray*)items navigationController:(OPNavigationController*)navigationController;

@end
