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

@property (strong, readonly) OPPhotoAlbum *photoAlbum;
@property (assign) NSInteger effectsState;
@property (strong) IBOutlet NSPageController *pageController;

-initWithPhotoAlbum:(OPPhotoAlbum*)album photo:(id<OPPhoto>)photo;

-(void)nextPhoto;
-(void)previousPhoto;

-(void)backToPhotoCollection;

-(void)deletePhoto;
-(void)revealInFinder;

//-(NSArray *)processedImages;

@end
