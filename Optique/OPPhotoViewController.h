//
//  OPPhotoViewController.h
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "OPNavigationViewController.h"
#import "OPPhotoAlbum.h"
#import "OPPhoto.h"

@interface OPPhotoViewController : OPNavigationViewController<NSCollectionViewDelegate, NSPageControllerDelegate>

@property (strong, readonly) id<OPPhotoCollection> collection;
@property (assign) NSInteger effectsState;
@property (strong) id<OPPhoto> currentPhoto;
@property (strong) IBOutlet NSPageController *pageController;

-initWithPhotoCollection:(id<OPPhotoCollection>)collection photo:(id<OPPhoto>)photo;

-(void)nextPhoto;
-(void)previousPhoto;

-(void)backToPhotoCollection;

-(void)deletePhoto;
-(void)revealInFinder;

//-(NSArray *)processedImages;

@end
