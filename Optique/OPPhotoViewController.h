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
#import "OPImageView.h"

@interface OPPhotoViewController : OPNavigationViewController

@property (strong, readonly) OPPhotoAlbum *photoAlbum;
@property (strong, readonly) OPPhoto *photo;
@property (strong) IBOutlet OPImageView *imageView;

-initWithPhotoAlbum:(OPPhotoAlbum*)album photo:(OPPhoto*)photo;

-(void)nextPhoto;

-(void)previousPhoto;

- (IBAction)rotateLeft:(id)sender;

@end
