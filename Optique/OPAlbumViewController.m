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
#import "OPDeleteAlbumSheetController.h"

@interface OPAlbumViewController () {
    NSInteger _itemsFoundWhenScanning;
    OPDeleteAlbumSheetController *_deleteAlbumSheetController;
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
    }
    return self;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumAdded:) name:OPPhotoManagerDidAddAlbum object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumDeleted:) name:OPPhotoManagerDidDeleteAlbum object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumUpdated:) name:OPPhotoManagerDidUpdateAlbum object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumsFound:) name:OPAlbumScannerDidFindAlbumsNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumsFinishedLoading:) name:OPAlbumScannerDidFinishScanNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPPhotoManagerDidAddAlbum object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPPhotoManagerDidDeleteAlbum object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPPhotoManagerDidUpdateAlbum object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumScannerDidFindAlbumsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumScannerDidFinishScanNotification object:nil];
}

-(void)loadView
{
    [super loadView];
    [_gridView setAllowsMultipleSelection:YES];
    [[_gridView enclosingScrollView] setDrawsBackground:NO];
}

-(void)showView
{
    [_gridView reloadData];
}

- (IBAction)revealInFinder:(NSMenuItem*)sender
{
    NSIndexSet *indexes = (NSIndexSet*)sender.representedObject;
    NSMutableArray *urls = [NSMutableArray array];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop)
    {
        OPPhotoAlbum *album = _photoManager.allAlbums[index];
        [urls addObject:album.path];
    }];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:urls];
}

- (IBAction)deleteAlbum:(NSMenuItem*)sender
{
    NSIndexSet *index = (NSIndexSet*)sender.representedObject;
    
    _deleteAlbumSheetController = [[OPDeleteAlbumSheetController alloc] initWithPhotoAlbums:[_photoManager albumsForIndexSet:index] photoManager:_photoManager];
    
    NSString *alertMessage;
    if (index.count > 1)
    {
        alertMessage = [NSString stringWithFormat:@"Do you want to delete the %lu selected albums?", index.count];
    }
    else
    {
        OPPhotoAlbum *album = [_deleteAlbumSheetController.albums lastObject];
        alertMessage = [NSString stringWithFormat:@"Do you want to delete '%@'?", album.title];
    }
    
    NSBeginAlertSheet(alertMessage, @"Delete", nil, @"Cancel", self.view.window, self, @selector(deleteSheetDidEndShouldClose:returnCode:contextInfo:), nil, nil, @"This operation can not be undone.", nil);
}

- (void)deleteSheetDidEndShouldClose: (NSWindow *)sheet
                    returnCode: (NSInteger)returnCode
                   contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        [sheet close];
        
        [NSApp beginSheet:_deleteAlbumSheetController.window modalForWindow:self.view.window modalDelegate:_deleteAlbumSheetController didEndSelector:nil contextInfo:nil];
        
        [_deleteAlbumSheetController startAlbumDeletion];
    }
}


- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    OPPhotoAlbum *photoAlbum = _photoManager.allAlbums[index];
    [self.controller pushViewController:[[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:photoAlbum photoManager:_photoManager]];
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
            [self performBlockOnMainThread:^{
                [_gridView reloadData];
            }];
        }
    }
}

-(void)albumUpdated:(NSNotification*)notification
{
    [self performBlockOnMainThread:^{
        OPPhotoManager *photoManager = [notification userInfo][@"photoManager"];
        
        if ([photoManager isEqual:_photoManager])
        {
            OPPhotoAlbum *album = [notification userInfo][@"album"];
            NSUInteger index = [_photoManager.allAlbums indexOfObject:album];
//            [_gridView redrawItemAtIndex:index];
            [_gridView reloadData];
        }
    }];
}

-(void)albumsFound:(NSNotification*)notification
{
    [self performBlockOnMainThread:^{
        OPPhotoManager *photoManager = [notification userInfo][@"photoManager"];
        
        if ([photoManager isEqual:_photoManager])
        {
            NSNumber *count = [notification userInfo][@"count"];
            _itemsFoundWhenScanning = count.integerValue;
            [self.controller updateNavigation];
        }
    }];
}

-(void)albumDeleted:(NSNotification*)notification
{
    [self performBlockOnMainThread:^{
        OPPhotoManager *photoManager = [notification userInfo][@"photoManager"];
        
        if ([photoManager isEqual:_photoManager])
        {
            [_gridView reloadData];
            [self.controller updateNavigation];
        }
    }];
}

-(void)albumsFinishedLoading:(NSNotification*)notification
{
    [self performBlockOnMainThread:^
    {
        OPPhotoManager *photoManager = [notification userInfo][@"photoManager"];
        
        if ([photoManager isEqual:_photoManager])
        {
            [self.controller updateNavigation];
        }
    }];
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
    item.representedObject = album;
    
    NSArray *allPhotos = album.allPhotos;
    
    if (allPhotos.count > 0)
    {
        OPPhoto *photo = allPhotos[0];
        
        CNGridViewItem * __weak weakItem = item;
        OPPhotoAlbum * __weak weakAlbum = album;
        
        item.itemImage = [[OPImagePreviewService defaultService] previewImageAtURL:photo.path loaded:^(NSImage *image)
        {
            [self performBlockOnMainThreadAndWaitUntilDone:^
            {
                if (weakItem.representedObject == weakAlbum)
                {
                    weakItem.itemImage = image;
                    [weakItem setNeedsDisplay:YES];
                }
            }];
        }];
    }
    else
    {
        item.itemImage = [NSImage imageNamed:@"empty-album"];
    }
    item.itemTitle = album.title;
    item.gridView = (OPPhotoGridView*)gridView;
    
    return item;
}

@end
