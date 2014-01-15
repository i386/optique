//
//  OPPhotoCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "OPPhotoCollectionViewController.h"
#import "OPPhotoViewController.h"
#import "OPImagePreviewService.h"
#import "OPPlaceHolderViewController.h"
#import "NSURL+Renamer.h"
#import "OPToolbarController.h"

@interface OPPhotoCollectionViewController()

@property (nonatomic, strong) NSMutableArray *sharingMenuItems;
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

-(BOOL)shareableItemsSelected
{
    return [self selectedItems].count > 0;
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
    OPPhotoGridViewCell *item = (OPPhotoGridViewCell *)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
    if (!item)
    {
        item = (OPPhotoGridViewCell *)[gridView dequeueReusableCell];
    }

    if (!item)
    {
        item = [self createPhotoGridViewCell];
    }
    
    
    NSOrderedSet *allPhotos = _collection.allPhotos;
    
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

-(BOOL)gridView:(OEGridView *)gridView keyDown:(NSEvent *)event
{
    if ([event keyCode] == kVK_Delete || [event keyCode] == kVK_ForwardDelete)
    {
        [self deleteSelected];
        return YES;
    }
    else if ([event keyCode] == kVK_Return)
    {
        NSIndexSet *indexes = gridView.selectionIndexes;
        if (indexes.count == 1)
        {
            [self gridView:gridView doubleClickedCellForItemAtIndex:indexes.lastIndex];
        }
        return YES;
    }
    return NO;
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
    
    self.gridView.disableCellReuse = YES;
}

-(void)loadView
{
    [super loadView];
    _contextMenu.delegate = self;
    [[_gridView enclosingScrollView] setDrawsBackground:NO];
    
    if ([_collection allPhotos].count == 0)
    {
        [_collection reload];
    }
    
    _primaryActionButton.boldText = YES;
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OPSharableSelectionChanged object:nil userInfo:nil];
}

-(id<NSPasteboardWriting>)gridView:(OEGridView *)gridView pasteboardWriterForIndex:(NSInteger)index
{
    return [self.collection allPhotos][index];
}

- (NSDragOperation)gridView:(OEGridView *)gridView validateDrop:(id<NSDraggingInfo>)sender
{
    return [self isFileDrop:sender] ? NSDragOperationCopy : NSDragOperationNone;
}

- (NSDragOperation)gridView:(OEGridView *)gridView draggingUpdated:(id<NSDraggingInfo>)sender
{
    return [self isFileDrop:sender] ? NSDragOperationCopy : NSDragOperationNone;
}

- (BOOL)gridView:(OEGridView *)gridView acceptDrop:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    id collection = _collection;
    if ( [[pboard types] containsObject:NSFilenamesPboardType] && [collection respondsToSelector:@selector(path)])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path isDirectory:&isDir] && !isDir)
        {
            NSString *fileName = [fileURL lastPathComponent];
            NSURL *destURL = (NSURL*)[collection path];
            destURL = [[destURL URLByAppendingPathComponent:fileName] URLWithUniqueNameIfExistsAtParent];
            
            NSError *error;
            [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:destURL error:&error];
            
            return error ? NO : YES;
        }
    }
    
    return NO;
}

-(BOOL)isFileDrop:(id<NSDraggingInfo>)sender
{
    id collection = _collection;
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] && [collection respondsToSelector:@selector(path)])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        
        BOOL isDir;
        return [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path isDirectory:&isDir] && !isDir;
    }
    return NO;
}

-(NSArray *)fileTypesForDraggingOperation:(OEGridView *)gridView
{
    NSMutableArray *extensions = [NSMutableArray array];
    for (id<XPPhoto> photo in [_collection photosForIndexSet:gridView.selectionIndexes])
    {
        [extensions addObject:[photo.url pathExtension]];
    }
    return extensions;
}

-(NSArray *)namesOfPromisedFilesDroppedForGrid:(OEGridView *)gridView atDestination:(NSURL *)dropDestination
{
    NSMutableArray *names = [NSMutableArray array];
    for (id<XPPhoto> photo in [_collection photosForIndexSet:gridView.selectionIndexes])
    {
        NSString *filename = [photo.url lastPathComponent];
        [names addObject:filename];
        
        [self performBlockInBackground:^{
            NSURL *destinationURL = [[dropDestination URLByAppendingPathComponent:filename] URLWithUniqueNameIfExistsAtParent];
            [[[NSFileManager alloc] init] copyItemAtURL:photo.url toURL:destinationURL error:nil];
        }];
    }
    
    [_photoManager collectionUpdated:_collection reload:YES];
    
    return names;
}

- (NSDragOperation)gridView:(OEGridView *)gridView draggingSourceOperationMaskForLocal:(BOOL)flag
{
    return flag ? NSDragOperationCopy : NSDragOperationNone;
}

@end
