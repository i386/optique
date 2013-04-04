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
#import "OPPhoto.h"
#import "OPAlbumScanner.h"
#import "OPPhotoGridItemView.h"
#import "OPImagePreviewService.h"

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
    if (album.allPhotos.count > 0)
    {
        OPPhoto *photo = album.allPhotos[0];
        item.itemImage = [[OPImagePreviewService defaultService] previewImageAtURL:photo.path loaded:^(NSImage *image) {
            [self performSelectorOnMainThread:@selector(update:) withObject:[NSNumber numberWithInteger:index] waitUntilDone:NO];
        }];
    }
    else
    {
        item.itemImage = [NSImage imageNamed:@"empty-album"];
    }
    item.itemTitle = album.title;
    
    return item;
}

-(void)update:(NSNumber*)index
{
    [_gridView redrawItemAtIndex:[index integerValue]];
}

@end
