//
//  OPPhotoCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "OPItemCollectionViewController.h"
#import "OPPItemViewController.h"
#import "OPImagePreviewService.h"
#import "OPPlaceHolderViewController.h"
#import "NSURL+Renamer.h"
#import "OPToolbarController.h"

@interface OPItemCollectionViewController()

@property (nonatomic, strong) NSMutableArray *sharingMenuItems;
@property (strong) OPPlaceHolderViewController *placeHolderViewController;

@end

@implementation OPItemCollectionViewController

-(id)initWithPhotoAlbum:(id<XPItemCollection>)collection collectionManager:(XPCollectionManager*)collectionManager
{
    self = [super initWithNibName:@"OPItemCollectionViewController" bundle:nil];
    if (self)
    {
        _collection = collection;
        _collectionManager = collectionManager;
        _sharingMenuItems = [NSMutableArray array];
        
        NSImage *placeHolderImage = [NSImage imageNamed:@"picture"];
        NSString *placeHolderText;
        if ([collection collectionType] == XPItemCollectionCamera)
        {
            id camera = collection;
            if ([camera respondsToSelector:@selector(isLocked)] && [camera isLocked])
            {
                placeHolderText = @"You will need to unlock this device before viewing its contents";
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumUpdated:) name:XPCollectionManagerDidUpdateCollection object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPCollectionManagerDidUpdateCollection object:nil];
}

-(id<XPItemCollection>)visibleCollection
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
    NSArray *items = [_collection itemsAtIndexes:indexes];
    
    NSString *message;
    if (items.count > 1)
    {
        message = [NSString stringWithFormat:@"Do you want to delete the %lu selected photos?", items.count];
    }
    else
    {
        id<XPItem> item = [items lastObject];
        message = [NSString stringWithFormat:@"Do you want to delete '%@'?", item.title];
    }
    
    NSBeginAlertSheet(message, @"Delete", nil, @"Cancel", self.view.window, self, @selector(deleteSheetDidEndShouldClose:returnCode:contextInfo:), nil, (void*)CFBridgingRetain(items), @"This operation can not be undone.");
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
        NSArray *items = CFBridgingRelease(contextInfo);
        
        volatile int __block itemCount = 0;
        [items each:^(id sender)
        {
            [_collection deletePhoto:sender withCompletion:^(NSError *error) {
                itemCount++;
            }];
        }];
        
        while (itemCount != items.count)
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
    OPPItemViewController *photoViewContoller = [[OPPItemViewController alloc] initWithItemCollection:_collection item:_collection.allItems[index]];
    [self.controller pushViewController:photoViewContoller];
}

-(NSUInteger)numberOfItemsInGridView:(OEGridView *)gridView
{
    return _collection.allItems.count;
}

-(OPItemGridViewCell*)createPhotoGridViewCell
{
    return [[OPItemGridViewCell alloc] init];
}

-(OEGridViewCell *)gridView:(OEGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    OPItemGridViewCell *cell = (OPItemGridViewCell *)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
    if (!cell)
    {
        cell = (OPItemGridViewCell *)[gridView dequeueReusableCell];
    }

    if (!cell)
    {
        cell = [self createPhotoGridViewCell];
    }
    
    
    NSOrderedSet *allPhotos = _collection.allItems;
    
    if (allPhotos.count > 0)
    {
        id<XPItem> item = allPhotos[index];
        cell.representedObject = item;
        
        OPItemGridViewCell * __weak weakCell = cell;
        id<XPItem> __weak weakItem = item;
        
        cell.image = [[OPImagePreviewService defaultService] previewImageWithItem:item loaded:^(NSImage *image)
                      {
                          [self performBlockOnMainThread:^
                           {
                               if (weakItem == weakCell.representedObject)
                               {
                                   cell.image = image;
                               }
                           }];
                      }];
        
        cell.view.toolTip = item.title;
        
        if (!cell.badgeLayer)
        {
            //Get badge layer from exposure
            for (id<XPItemCollectionProvider> provider in [XPExposureService itemCollectionProviders])
            {
                if ([provider respondsToSelector:@selector(badgeLayerForPhoto:)])
                {
                    cell.badgeLayer = [provider badgeLayerForPhoto:item];
                    if (cell.badgeLayer)
                    {
                        break;
                    }
                }
            }
        }
    }
    
    return cell;
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
    [XPExposureService collectionManager:_collectionManager itemCollectionViewController:self];
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
    
    if ([_collection allItems].count == 0)
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
    
    NSMutableSet *collections = [NSMutableSet setWithArray:_collectionManager.allCollections];
    [collections removeObject:_collection];
    
    [collections each:^(id<XPItemCollection> collection)
    {
        if ([collection collectionType] == XPItemCollectionLocal)
        {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:collection.title action:@selector(moveToCollection:) keyEquivalent:[NSString string]];
            item.target = self;
            [item setRepresentedObject:collection];
            [_moveToAlbumItem.submenu addItem:item];
        }
    }];
    
    [XPExposureService menuVisiblity:_contextMenu items:[collections allObjects]];
}
    
-(void)moveToCollection:(NSMenuItem*)item
{
    id<XPItemCollection> collection = item.representedObject;
    NSIndexSet *indexes = [_gridView indexesForSelectedCells];
    NSArray *items = [_collection itemsAtIndexes:indexes];
    
    [items each:^(id<XPItem> item)
    {
        [collection addPhoto:item withCompletion:nil];
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
    OPItemGridView *itemGridView = (OPItemGridView*)gridView;
    
    if (itemGridView.isSelectionSticky)
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
    return [self.collection allItems][index];
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
    for (id<XPItem> item in [_collection itemsAtIndexes:gridView.selectionIndexes])
    {
        [extensions addObject:[item.url pathExtension]];
    }
    return extensions;
}

-(NSArray *)namesOfPromisedFilesDroppedForGrid:(OEGridView *)gridView atDestination:(NSURL *)dropDestination
{
    NSMutableArray *names = [NSMutableArray array];
    for (id<XPItem> item in [_collection itemsAtIndexes:gridView.selectionIndexes])
    {
        NSString *filename = [item.url lastPathComponent];
        [names addObject:filename];
        
        [self performBlockInBackground:^{
            NSURL *destinationURL = [[dropDestination URLByAppendingPathComponent:filename] URLWithUniqueNameIfExistsAtParent];
            [[[NSFileManager alloc] init] copyItemAtURL:item.url toURL:destinationURL error:nil];
        }];
    }
    
    [_collectionManager collectionUpdated:_collection reload:YES];
    
    return names;
}

- (NSDragOperation)gridView:(OEGridView *)gridView draggingSourceOperationMaskForLocal:(BOOL)flag
{
    return flag ? NSDragOperationCopy : NSDragOperationNone;
}

@end
