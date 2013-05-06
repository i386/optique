//
//  OPPhotoViewController.h
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "OPNavigationViewController.h"

@interface OPPhotoViewController : OPNavigationViewController<NSCollectionViewDelegate, NSPageControllerDelegate, XPPhotoViewController>

@property (strong, readonly) id<XPPhotoCollection> collection;
@property (assign) NSInteger effectsState;
@property (strong) id<XPPhoto> currentPhoto;
@property (strong) IBOutlet NSPageController *pageController;

-initWithPhotoCollection:(id<XPPhotoCollection>)collection photo:(id<XPPhoto>)photo;

-(void)nextPhoto;
-(void)previousPhoto;

-(void)backToPhotoCollection;

-(void)deletePhoto;
-(void)revealInFinder;

//-(NSArray *)processedImages;

@end
