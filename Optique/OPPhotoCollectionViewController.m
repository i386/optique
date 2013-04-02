//
//  OPPhotoCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoCollectionViewController.h"
#import "OPPhotoViewController.h"
#import "OPPhotoGridItemView.h"
#import "CNGridViewItemLayout.h"
#import "OPPhotoGridView.h"

@interface OPPhotoCollectionViewController ()

@end

@implementation OPPhotoCollectionViewController

-(id)initWithPhotoAlbum:(OPPhotoAlbum *)photoAlbum
{
    self = [super initWithNibName:@"OPPhotoCollectionViewController" bundle:nil];
    if (self)
    {
        _photoAlbum = photoAlbum;
    }
    
    return self;
}

-(NSString *)viewTitle
{
    return _photoAlbum.title;
}

- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    OPPhotoViewController *photoViewContoller = [[OPPhotoViewController alloc] initWithPhotoAlbum:_photoAlbum photo:_photoAlbum.allPhotos[index]];
    [self.controller pushViewController:photoViewContoller];
}

- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    return _photoAlbum.allPhotos.count;
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section
{
    OPPhotoGridItemView *item = [gridView dequeueReusableItemWithIdentifier:(NSString*)OPPhotoGridViewReuseIdentifier];
    if (item == nil) {
        item = [[OPPhotoGridItemView alloc] initWithLayout:nil reuseIdentifier:(NSString*)OPPhotoGridViewReuseIdentifier];
    }
    
    OPPhotoAlbum *album = _photoAlbum.allPhotos[index];
    item.itemImage = album.coverImage;
    item.itemTitle = album.title;
    
    self.gridView.itemSize = NSMakeSize(310, 225);
    
    return item;
}

-(void)loadView
{
    [super loadView];
    
    [_gridView reloadData];
}

@end
