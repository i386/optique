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
        _albums = [[NSMutableArray alloc] init];
        _photoManager = photoManager;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumAdded:) name:OPPhotoManagerDidAddAlbum object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumsFound:) name:OPAlbumScannerDidFindAlbumsNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumsFinishedLoading:) name:OPAlbumScannerDidFinishScanNotification object:nil];
    }
    return self;
}

- (void)doubleClick:(id)sender
{
    OPPhotoAlbum *photoAlbum = [sender representedObject];
    [self.controller pushViewController:[[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:photoAlbum]];
}

-(NSString *)viewTitle
{
    NSInteger currentAlbumCount = _albums.count;
    if (currentAlbumCount > 0 && _itemsFoundWhenScanning >= 1 && currentAlbumCount != _itemsFoundWhenScanning)
    {
        return [NSString stringWithFormat:@"Loading %lu of %li albums", (unsigned long)_albums.count, _itemsFoundWhenScanning];
    }
    else if (currentAlbumCount > 0)
    {
        return [NSString stringWithFormat:@"%lu albums", (unsigned long)_albums.count];
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
        [self willChangeValueForKey:@"self.albums"];
        
        [_albumArrayController addObject:album];
        
        [self didChangeValueForKey:@"self.albums"];
        
        [self.controller updateNavigationBar];
    }
}

@end
