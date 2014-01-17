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

@property (weak, readonly) id<XPItemCollection> collection;
@property (assign) NSInteger effectsState;
@property (weak) id<XPItem> item;
@property (weak) IBOutlet NSPageController *pageController;
@property (weak) IBOutlet NSMenu *contextMenu;

-initWithItemCollection:(id<XPItemCollection>)collection item:(id<XPItem>)item;

-(void)nextPhoto;
-(void)previousPhoto;

-(void)backToPhotoCollection;

-(void)deletePhoto;

@end
