//
//  OPPhotoViewController.h
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationViewController.h"
#import "OPPhotoAlbum.h"
#import "OPPhoto.h"

@interface OPPhotoViewController : OPNavigationViewController

@property (strong, readonly) OPPhotoAlbum *photoAlbum;
@property (strong, readonly) OPPhoto *photo;

-initWithPhotoAlbum:(OPPhotoAlbum*)album photo:(OPPhoto*)photo;

-(void)nextPhoto;

-(void)previousPhoto;

@end
