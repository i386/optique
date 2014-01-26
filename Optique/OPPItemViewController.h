//
//  OPPhotoViewController.h
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "OPNavigationViewController.h"

@interface OPPItemViewController : OPNavigationViewController<NSCollectionViewDelegate, NSPageControllerDelegate, XPSharingService, XPItemController, NSMenuDelegate>

@property (weak) id<XPItem> item;
@property (weak) IBOutlet NSPageController *pageController;
@property (weak) IBOutlet NSMenu *contextMenu;

-initWithItem:(id<XPItem>)item;

-(void)next;
-(void)previous;

-(void)backToCollection;

-(void)deleteItem;

@end
