//
//  OPPhotoCollectionViewController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationViewController.h"
#import "OPPhotoAlbum.h"

@interface OPPhotoCollectionViewController : OPNavigationViewController <NSCollectionViewDelegate>

@property (strong, readonly) OPPhotoAlbum *photoAlbum;

-initWithPhotoAlbum:(OPPhotoAlbum*)photoAlbum;

- (void)doubleClick:(id)sender;

@end
