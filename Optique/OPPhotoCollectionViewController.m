//
//  OPPhotoCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoCollectionViewController.h"
#import "OPPhotoViewController.h"
#import "OPImagePreviewService.h"
#import "OPPlaceHolderViewController.h"

@interface OPPhotoCollectionViewController()

@property (strong) NSMutableArray *sharingMenuItems;
@property (strong) OPPlaceHolderViewController *placeHolderViewController;

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
        
        NSImage *placeHolderImage = [NSImage imageNamed:@"picture"];
        NSString *placeHolderText;
        if ([collection collectionType] == kPhotoCollectionCamera)
        {
            id camera = collection;
            if ([camera respondsToSelector:@selector(isLocked)] && [camera isLocked])
            {
                placeHolderText = @"You will need to unlock this device before viewing photos";
                placeHolderImage = [NSImage imageNamed:@"lock"];
            }
            else
            {
                placeHolderText = @"There are no photos on this camera";
            }
        }
        else
        {
            placeHolderText = @"There are no photos in this album";
        }
        
        _placeHolderViewController = [[OPPlaceHolderViewController alloc] initWithText:placeHolderText image:placeHolderImage];
        
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
        
        [self reloadData];
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

-(OPPhotoGridViewCell*)createPhotoGridViewCell
{
    return [[OPPhotoGridViewCell alloc] init];
}

-(OEGridViewCell *)gridView:(OEGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    OPPhotoGridViewCell *item = [self createPhotoGridViewCell];
                                 
    NSArray *allPhotos = _collection.allPhotos;
    
    if (allPhotos.count > 0)
    {
        id<XPPhoto> photo = allPhotos[index];
        item.representedObject = photo;
        
        OPPhotoGridViewCell * __weak weakItem = item;
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
        
        item.view.toolTip = photo.title;
        
        if (!item.badgeLayer)
        {
            //Get badge layer from exposure
            for (id<XPPhotoCollectionProvider> provider in [XPExposureService photoCollectionProviders])
            {
                if ([provider respondsToSelector:@selector(badgeLayerForPhoto:)])
                {
                    item.badgeLayer = [provider badgeLayerForPhoto:photo];
                    if (item.badgeLayer)
                    {
                        break;
                    }
                }
            }
        }
    }
    
    return item;
}

-(void)albumUpdated:(NSNotification*)notification
{
    [self performBlockOnMainThread:^
    {
        [self reloadData];
    }];
}

-(void)awakeFromNib
{
    [XPExposureService photoManager:_photoManager photoCollectionViewController:self];
    [_headingLine setBorderWidth:2];
    [_headingLine setBorderColor:[NSColor colorWithCalibratedRed:0.83 green:0.83 blue:0.83 alpha:1.00]];
    [_headingLine setBoxType:NSBoxCustom];
    
    [[_primaryActionButton cell] setKBButtonType:BButtonTypePrimary];
    [[_secondaryActionButton cell] setKBButtonType:BButtonTypeDefault];
    
//    self.gridView.isSelectionSticky = YES;
}

-(void)loadView
{
    [super loadView];
    _contextMenu.delegate = self;
    [[_gridView enclosingScrollView] setDrawsBackground:NO];
}

-(void)showView
{
    [self reloadData];
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

-(void)reloadData
{
    [self willChangeValueForKey:@"collection"];
    [_gridView reloadData];
    [self didChangeValueForKey:@"collection"];
}

-(NSView *)viewForNoItemsInGridView:(OEGridView *)gridView
{
    _placeHolderViewController.view.frame = gridView.frame;
    return _placeHolderViewController.view;
}

- (IBAction)primaryActionActivated:(id)sender
{
}

-(void)secondaryActionActivated:(id)sender
{
    [[self gridView] deselectAll:sender];
}

-(void)selectionChangedInGridView:(OEGridView *)gridView
{
    OPPhotoGridView *photoGridView = (OPPhotoGridView*)gridView;
    
    if (photoGridView.isSelectionSticky)
    {
        if (gridView.selectionIndexes.count > 0)
        {
            [[self primaryActionButton] setHidden:NO];
            [[self secondaryActionButton] setHidden:NO];
            [[self dateLabel] setHidden:YES];
        }
        else
        {
            [[self primaryActionButton] setHidden:YES];
            [[self secondaryActionButton] setHidden:YES];
            [[self dateLabel] setHidden:NO];
        }
    }
}
@end
