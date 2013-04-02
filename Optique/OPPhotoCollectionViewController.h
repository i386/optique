//
//  OPPhotoCollectionViewController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationViewController.h"
#import "OPPhotoAlbum.h"
#import "OPPhotoGridView.h"

@interface OPPhotoCollectionViewController : OPNavigationViewController <CNGridViewDataSource, CNGridViewDelegate>

@property (strong, readonly) OPPhotoAlbum *photoAlbum;
@property (strong) IBOutlet CNGridView *gridView;

-initWithPhotoAlbum:(OPPhotoAlbum*)photoAlbum;

@end
