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
#import "OPNavigationViewController.h"

@interface OPAlbumViewController : OPNavigationViewController <NSCollectionViewDelegate>

@property (strong, readonly) OPPhotoManager *photoManager;
@property (strong, readonly) NSMutableArray *albums;
@property (strong) IBOutlet OPAlbumCollectionView *collectionView;
@property (strong) IBOutlet NSArrayController *albumArrayController;

-initWithPhotoManager:(OPPhotoManager*)photoManager;

- (void)doubleClick:(id)sender;

@end
