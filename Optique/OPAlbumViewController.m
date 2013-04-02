//
//  OPAlbumViewController.m
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAlbumViewController.h"

#import "OPPhotoCollectionViewController.h"
#import "OPPhotoManager.h"
#import "OPAlbumScanner.h"
#import "OPPhotoGridItemView.h"

@interface OPAlbumViewController () {
    NSInteger _itemsFoundWhenScanning;
}
@end

@implementation OPAlbumViewController

-(id)initWithPhotoManager:(OPPhotoManager *)photoManager
{
    self = [super initWithNibName:@"OPAlbumViewController" bundle:nil];
    if (self)
    {
        _itemsFoundWhenScanning = 0;
        _albumCountsDuringScan = 0;
        _photoManager = photoManager;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumAdded:) name:OPPhotoManagerDidAddAlbum object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumsFound:) name:OPAlbumScannerDidFindAlbumsNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumsFinishedLoading:) name:OPAlbumScannerDidFinishScanNotification object:nil];
    }
    return self;
}

- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    OPPhotoAlbum *photoAlbum = _photoManager.allAlbums[index];
    [self.controller pushViewController:[[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:photoAlbum]];
}

-(NSString *)viewTitle
{
    if (_itemsFoundWhenScanning > 0 && _itemsFoundWhenScanning >= 1 && _itemsFoundWhenScanning != _itemsFoundWhenScanning)
    {
        return [NSString stringWithFormat:@"Loading %li of %li albums", _itemsFoundWhenScanning, _itemsFoundWhenScanning];
    }
    else if (_itemsFoundWhenScanning > 0)
    {
        return [NSString stringWithFormat:@"%li albums", _itemsFoundWhenScanning];
    }
    return [NSString string];
}

-(void)albumAdded:(NSNotification*)notification
{
    OPPhotoManager *photoManager = [notification userInfo][@"photoManager"];
    
    if ([photoManager isEqual:_photoManager])
    {
        OPPhotoAlbum *album = [notification userInfo][@"album"];
        if (album)
        {
            [self performSelectorOnMainThread:@selector(updateAlbums:) withObject:album waitUntilDone:NO];
        }
    }
}

-(void)albumsFound:(NSNotification*)notification
{
    OPPhotoManager *photoManager = [notification userInfo][@"photoManager"];
    
    if ([photoManager isEqual:_photoManager])
    {
        NSNumber *count = [notification userInfo][@"count"];
        _itemsFoundWhenScanning = count.integerValue;
        [self.controller updateNavigationBar];
    }
}

-(void)albumsFinishedLoading:(NSNotification*)notification
{
    OPPhotoManager *photoManager = [notification userInfo][@"photoManager"];
    
    if ([photoManager isEqual:_photoManager])
    {
        [self.controller updateNavigationBar];
    }
}

-(void)updateAlbums:(OPPhotoAlbum*)album
{
    if (album)
    {
        [_gridView reloadData];
    }
}

- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    return _photoManager.allAlbums.count;
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section
{
    OPPhotoGridItemView *item = [gridView dequeueReusableItemWithIdentifier:(NSString*)OPPhotoGridViewReuseIdentifier];
    if (item == nil) {
        item = [[OPPhotoGridItemView alloc] initWithLayout:nil reuseIdentifier:(NSString*)OPPhotoGridViewReuseIdentifier];
    }
    
    OPPhotoAlbum *album = _photoManager.allAlbums[index];
    item.itemImage = album.coverImage;
    item.itemTitle = album.title;
    
    self.gridView.itemSize = NSMakeSize(310, 225);
    
    return item;
}

@end
