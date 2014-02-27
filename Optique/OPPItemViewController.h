//
//  OPPhotoViewController.h
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "OPSlideView.h"

@interface OPPItemViewController : NSViewController <XPNavigationViewController, NSCollectionViewDelegate, WHSlideViewDelegate, XPSharingService, XPItemController, NSMenuDelegate>

@property (assign) id<XPNavigationController> controller;
@property (weak) id<XPItem> item;
@property (weak) IBOutlet NSMenu *contextMenu;
@property (weak) IBOutlet OPSlideView *slideView;

-initWithItem:(id<XPItem>)item;

-(void)next;
-(void)previous;

-(void)backToCollection;

-(void)deleteItem;

@end
