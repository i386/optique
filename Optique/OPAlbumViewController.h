//
//  OPAlbumViewController.h
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CNGridView/CNGridView.h>

#import "OPPhotoManager.h"
#import "OPEffectCollectionView.h"
#import "OPNavigationViewController.h"

@interface OPAlbumViewController : OPNavigationViewController <CNGridViewDataSource, CNGridViewDelegate> {
    NSUInteger _albumCountsDuringScan;
}

@property (strong, readonly) OPPhotoManager *photoManager;
@property (strong) IBOutlet CNGridView *gridView;

-initWithPhotoManager:(OPPhotoManager*)photoManager;

@end
