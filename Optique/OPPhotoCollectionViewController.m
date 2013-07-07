//
//  OPPhotoCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoCollectionViewController.h"
#import "OPPhotoViewController.h"
#import "OPGridViewCell.h"
#import "OPImagePreviewService.h"

@interface OPPhotoCollectionViewController () {
    NSMutableArray *_sharingMenuItems;
}
@end

@implementation OPPhotoCollectionViewController

-(id)initWithPhotoAlbum:(id<XPPhotoCollection>)collection photoManager:(XPPhotoManager*)photoManager
{
    self = [super initWithNibName:@"OPPhotoCollectionViewController" bundle:nil];
    if (self)
    {
        _collection = collection;
        _photoManager = photoManager;
        _sharingMenuItems = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumUpdated:) name:XPPhotoManagerDidUpdateCollection object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidUpdateCollection object:nil];
}

-(id<XPPhotoCollection>)visibleCollection
{
    return _collection;
}

-(NSWindow *)window
{
    return self.view.window;
}

-(NSIndexSet *)selectedItems
{
    return _gridView.indexesForSelectedCells;
}

-(NSMutableArray *)sharingMenuItems
{
    return _sharingMenuItems;
}

-(void)deleteSelected
{
    NSIndexSet *indexes = _gridView.indexesForSelectedCells;
    [self deleteSelectedPhotosAtIndexes:indexes];
}

-(void)deleteSelectedPhotosAtIndexes:(NSIndexSet*)indexes
{
    NSArray *photos = [_collection photosForIndexSet:indexes];
    
    NSString *message;
    if (photos.count > 1)
    {
        message = [NSString stringWithFormat:@"Do you want to delete the %lu selected photos?", photos.count];
    }
    else
    {
        id<XPPhoto> photo = [photos lastObject];
        message = [NSString stringWithFormat:@"Do you want to delete '%@'?", photo.title];
    }
    
    NSBeginAlertSheet(message, @"Delete", nil, @"Cancel", self.view.window, self, @selector(deleteSheetDidEndShouldClose:returnCode:contextInfo:), nil, (void*)CFBridgingRetain(photos), @"This operation can not be undone.");
}

- (IBAction)deletePhoto:(NSMenuItem*)sender
{
    NSIndexSet *indexes = [_gridView selectionIndexes];
    [self deleteSelectedPhotosAtIndexes:indexes];
}

- (void)deleteSheetDidEndShouldClose: (NSWindow *)sheet
                          returnCode: (NSInteger)returnCode
                         contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        NSArray *photos = CFBridgingRelease(contextInfo);
        
        volatile int __block photosAdded = 0;
        [photos each:^(id sender)
        {
            [_collection deletePhoto:sender withCompletion:^(NSError *error) {
                photosAdded++;
            }];
        }];
        
        while (photosAdded != photos.count)
        {
            [NSThread sleepForTimeInterval:1];
        }
        
        [_gridView reloadData];
    }
}

-(NSString *)viewTitle
{
    return _collection.title;
}

-(NSMenu *)gridView:(OEGridView *)gridView menuForItemsAtIndexes:(NSIndexSet *)indexes
{
    return _contextMenu;
}

-(void)gridView:(OEGridView *)gridView doubleClickedCellForItemAtIndex:(NSUInteger)index
{
    OPPhotoViewController *photoViewContoller = [[OPPhotoViewController alloc] initWithPhotoCollection:_collection photo:_collection.allPhotos[index]];
    [self.controller pushViewController:photoViewContoller];
}

-(NSUInteger)numberOfItemsInGridView:(OEGridView *)gridView
{
    return _collection.allPhotos.count;
}

-(OEGridViewCell *)gridView:(OEGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
//    OPGridViewCell *item = (OPGridViewCell *)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
//    if (!item) {
//        item = (OPGridViewCell *)[gridView dequeueReusableCell];
//    }
//    if (!item) {
//        item = [[OPGridViewCell alloc] init];
//    }
    
    OPGridViewCell *item = [[OPGridViewCell alloc] init];
    
    NSArray *allPhotos = _collection.allPhotos;
    
    if (allPhotos.count > 0)
    {
        id<XPPhoto> photo = allPhotos[index];
        item.representedObject = photo;
        
        OPGridViewCell * __weak weakItem = item;
        id<XPPhoto> __weak weakPhoto = photo;
        
        item.image = [[OPImagePreviewService defaultService] previewImageWithPhoto:photo loaded:^(NSImage *image)
        {
            [self performBlockOnMainThread:^
            {
                if (weakPhoto == weakItem.representedObject)
                {
                    weakItem.image = image;
                }
            }];
        }];
        
        item.title = photo.title;
        item.view.toolTip = photo.title;
    }
    
    return item;
}

-(void)albumUpdated:(NSNotification*)notification
{
    [self performBlockOnMainThread:^
    {
        [_gridView reloadData];
    }];
}

-(void)awakeFromNib
{
    [OPExposureService photoManager:_photoManager photoCollectionViewController:self];
}

-(void)loadView
{
    [super loadView];
    _contextMenu.delegate = self;
    [[_gridView enclosingScrollView] setDrawsBackground:NO];
}

-(void)showView
{
    [_gridView reloadData];
}

-(void)menuNeedsUpdate:(NSMenu *)menu
{
    _moveToAlbumItem.submenu = [[NSMenu alloc] init];
    
    NSMutableSet *collections = [NSMutableSet setWithArray:_photoManager.allCollections];
    [collections removeObject:_collection];
    
    [collections each:^(id<XPPhotoCollection> collection)
    {
        if ([collection collectionType] == kPhotoCollectionLocal)
        {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:collection.title action:@selector(moveToCollection:) keyEquivalent:[NSString string]];
            item.target = self;
            [item setRepresentedObject:collection];
            [_moveToAlbumItem.submenu addItem:item];
        }
    }];
}
    
-(void)moveToCollection:(NSMenuItem*)item
{
    id<XPPhotoCollection> collection = item.representedObject;
    NSIndexSet *indexes = [_gridView indexesForSelectedCells];
    NSArray *photos = [_collection photosForIndexSet:indexes];
    
    [photos each:^(id<XPPhoto> photo)
    {
        [collection addPhoto:photo withCompletion:nil];
    }];
}

@end
