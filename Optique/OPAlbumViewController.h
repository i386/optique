//
//  OPAlbumViewController.h
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "OPPhotoManager.h"
#import "OPAlbumCollectionView.h"
#import "OPPhotoAlbumViewController.h"

@interface OPAlbumViewController : NSViewController <NSCollectionViewDelegate>

@property (strong, readonly) OPPhotoManager *photoManager;
@property (strong) IBOutlet OPAlbumCollectionView *collectionView;

-initWithPhotoManager:(OPPhotoManager*)photoManager;

@end
