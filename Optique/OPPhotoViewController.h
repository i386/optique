//
//  OPPhotoViewController.h
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "OPNavigationViewController.h"

@interface OPPhotoViewController : OPNavigationViewController<NSCollectionViewDelegate, NSPageControllerDelegate, XPSharingService, XPPhotoController, NSMenuDelegate>

@property (weak, readonly) id<XPPhotoCollection> collection;
@property (assign) NSInteger effectsState;
@property (weak) id<XPPhoto> visiblePhoto;
@property (weak) IBOutlet NSPageController *pageController;
@property (weak) IBOutlet NSMenu *contextMenu;

-initWithPhotoCollection:(id<XPPhotoCollection>)collection photo:(id<XPPhoto>)photo;

-(void)nextPhoto;
-(void)previousPhoto;

-(void)backToPhotoCollection;

-(void)deletePhoto;

@end
