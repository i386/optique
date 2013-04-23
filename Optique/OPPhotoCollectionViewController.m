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
#import "OPImagePreviewService.h"

@interface OPPhotoCollectionViewController ()

@end

@implementation OPPhotoCollectionViewController

-(id)initWithPhotoAlbum:(OPPhotoAlbum *)photoAlbum photoManager:(OPPhotoManager*)photoManager
{
    self = [super initWithNibName:@"OPPhotoCollectionViewController" bundle:nil];
    if (self)
    {
        _photoAlbum = photoAlbum;
        _photoManager = photoManager;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumUpdated:) name:OPPhotoManagerDidUpdateAlbum object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPPhotoManagerDidUpdateAlbum object:nil];
}

- (IBAction)revealInFinder:(NSMenuItem*)sender
{
    NSIndexSet *indexes = (NSIndexSet*)sender.representedObject;
    NSMutableArray *urls = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        OPPhoto *photo = _photoAlbum.allPhotos[index];
        [urls addObject:photo.path];
    }];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:urls];
}

- (IBAction)deletePhoto:(id)sender
{
    NSMenuItem *item = sender;
    NSIndexSet *indexes = item.representedObject;
    
    NSArray *photos = [_photoAlbum photosForIndexSet:indexes];
    
    NSString *message;
    if (photos.count > 1)
    {
        message = [NSString stringWithFormat:@"Do you want to delete the %lu selected photos?", photos.count];
    }
    else
    {
        OPPhoto *photo = [photos lastObject];
        message = [NSString stringWithFormat:@"Do you want to delete '%@'?", photo.title];
    }
    
    NSBeginAlertSheet(message, @"Delete", nil, @"Cancel", self.view.window, self, @selector(deleteSheetDidEndShouldClose:returnCode:contextInfo:), nil, (void*)CFBridgingRetain(photos), @"This operation can not be undone.");
}

- (void)deleteSheetDidEndShouldClose: (NSWindow *)sheet
                          returnCode: (NSInteger)returnCode
                         contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        NSArray *photos = CFBridgingRelease(contextInfo);
        
        [photos each:^(id sender)
        {
            [_photoAlbum deletePhoto:sender error:nil];
        }];
        
        [_gridView reloadData];
    }
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
    if (item == nil)
    {
        item = [[OPPhotoGridItemView alloc] initWithLayout:nil reuseIdentifier:(NSString*)OPPhotoGridViewReuseIdentifier];
    }
    
    NSArray *allPhotos = _photoAlbum.allPhotos;
    
    if (allPhotos.count > 0)
    {
        OPPhoto *photo = allPhotos[index];
        item.representedObject = photo;
        
        CNGridViewItem * __weak weakItem = item;
        OPPhoto * __weak weakPhoto = photo;
        
        item.itemImage = [[OPImagePreviewService defaultService] previewImageAtURL:photo.path loaded:^(NSImage *image)
        {
            [self performBlockOnMainThreadAndWaitUntilDone:^
            {
                if (weakPhoto == weakItem.representedObject)
                {
                    weakItem.itemImage = image;
                    [weakItem setNeedsDisplay:YES];
                }
            }];
        }];
        
        item.itemTitle = photo.title;
    }
    
    item.gridView = (OPPhotoGridView*)gridView;
    
    return item;
}

-(void)albumUpdated:(NSNotification*)notification
{
    [self performBlockOnMainThread:^
    {
        [_gridView reloadData];
    }];
}

-(void)loadView
{
    [super loadView];
    [_gridView setAllowsMultipleSelection:YES];
    _contextMenu.delegate = self;
}

-(void)showView
{
    [_gridView reloadData];
}

-(void)menuNeedsUpdate:(NSMenu *)menu
{
    _moveToAlbumItem.submenu = [[NSMenu alloc] init];
    
    NSMutableSet *albums = [NSMutableSet setWithArray:_photoManager.allAlbums];
    [albums removeObject:_photoAlbum];
    
    [albums each:^(OPPhotoAlbum *album)
    {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:album.title action:@selector(moveToAlbum:) keyEquivalent:[NSString string]];
        item.target = self;
        [item setRepresentedObject:album];
        [_moveToAlbumItem.submenu addItem:item];
    }];
}

-(void)moveToAlbum:(NSMenuItem*)item
{
    OPPhotoAlbum *album = item.representedObject;
    NSIndexSet *indexes = [_gridView selectedIndexes];
    NSArray *photos = [_photoAlbum photosForIndexSet:indexes];
    
    [photos each:^(OPPhoto *photo)
    {
        [photo.album movePhoto:photo toAlbum:album];
    }];
}

@end
