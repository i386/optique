//
//  OPPhotoViewController.h
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "OPSlideView.h"
#import "OPNavigationViewController.h"

@interface OPPItemViewController : OPNavigationViewController<NSCollectionViewDelegate, WHSlideViewDelegate, XPSharingService, XPItemController, NSMenuDelegate>

@property (weak) id<XPItem> item;
@property (weak) IBOutlet NSMenu *contextMenu;
@property (weak) IBOutlet WHSlideView *slideView;

-initWithItem:(id<XPItem>)item;

-(void)next;
-(void)previous;

-(void)backToCollection;

-(void)deleteItem;

@end
