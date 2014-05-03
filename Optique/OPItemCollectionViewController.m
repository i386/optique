//
//  OPPhotoCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Carbon/Carbon.h>
#import <QuartzCore/QuartzCore.h>
#import "OPItemCollectionViewController.h"
#import "OPPItemViewController.h"
#import "OPItemPreviewManager.h"
#import "OPPlaceHolderViewController.h"
#import "NSURL+Renamer.h"
#import "OPToolbarController.h"
#import "NSURL+ImageType.h"
#import "NSData+WriteImage.h"

@interface OPItemCollectionViewController()

@property (nonatomic, strong) NSMutableArray *sharingMenuItems;
@property (strong) OPPlaceHolderViewController *placeHolderViewController;

@end

@implementation OPItemCollectionViewController

-(id)initWithIemCollection:(id<XPItemCollection>)collection collectionManager:(XPCollectionManager*)collectionManager
{
    self = [super initWithNibName:@"OPItemCollectionViewController" bundle:nil];
    if (self)
    {
        _collection = collection;
        _collectionManager = collectionManager;
        _sharingMenuItems = [NSMutableArray array];
        
        NSImage *placeHolderImage = [NSImage imageNamed:@"folder-small"];
        NSString *placeHolderText;
        if (collection.collectionType == XPItemCollectionCamera)
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadItem:) name:XPItemWillReload object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPCollectionManagerDidUpdateCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPItemWillReload object:nil];
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
    [self deleteSelectedItemsAtIndexes:indexes];
}

-(void)deleteSelectedItemsAtIndexes:(NSIndexSet*)indexes
{
    NSArray *items = [_collection itemsAtIndexes:indexes];
    
    NSString *message;
    if (items.count > 1)
    {
        message = [NSString stringWithFormat:@"Do you want to delete the %lu selected items?", items.count];
    }
    else
    {
        id<XPItem> item = [items lastObject];
        message = [NSString stringWithFormat:@"Do you want to delete '%@'?", item.title];
    }
    
    NSBeginAlertSheet(message, @"Delete", nil, @"Cancel", self.view.window, self, @selector(deleteSheetDidEndShouldClose:returnCode:contextInfo:), nil, (void*)CFBridgingRetain(items), @"This operation can not be undone.");
}

- (IBAction)deleteItem:(NSMenuItem*)sender
{
    NSIndexSet *indexes = [_gridView selectionIndexes];
    [self deleteSelectedItemsAtIndexes:indexes];
}

- (void)deleteSheetDidEndShouldClose: (NSWindow *)sheet
                          returnCode: (NSInteger)returnCode
                         contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        NSArray *items = CFBridgingRelease(contextInfo);
        
        volatile int __block itemCount = 0;
        [items bk_each:^(id sender)
        {
            [_collection deleteItem:sender withCompletion:^(NSError *error) {
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
    OPPItemViewController *controller = [[OPPItemViewController alloc] initWithItem:_collection.allItems[index]];
    [self.controller pushViewController:controller];
}

-(NSUInteger)numberOfItemsInGridView:(OEGridView *)gridView
{
    return _collection.allItems.count;
}

-(OPItemGridViewCell*)createItemGridViewCell:(id<XPItem>)item
{
    return [[OPItemGridViewCell alloc] init];
}

-(OEGridViewCell *)gridView:(OEGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    NSOrderedSet *items = _collection.allItems;
    
    if (items.count > 0)
    {
        id<XPItem> item = items[index];
        
        OPItemGridViewCell *cell = (OPItemGridViewCell *)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
        if (!cell)
        {
            cell = (OPItemGridViewCell *)[gridView dequeueReusableCell];
        }
        
        if (!cell)
        {
            cell = [self createItemGridViewCell:item];
        }
        
        cell.representedObject = item;
        
        OPItemGridViewCell * __weak weakCell = cell;
        id<XPItem> __weak weakItem = item;
        
        [[OPItemPreviewManager defaultManager] previewItem:item size:_gridView.itemSize loaded:^(NSImage *image) {
            [self performBlockOnMainThread:^
             {
                 if (weakItem == weakCell.representedObject)
                 {
                     weakCell.image = image;
                 }
             }];
        }];
        
        cell.view.toolTip = item.title;
        
        if (!cell.badgeLayer)
        {
            //Get badge layer from exposure
            for (id<XPItemCollectionProvider> provider in [XPExposureService itemCollectionProviders])
            {
                if ([provider respondsToSelector:@selector(badgeLayerForItem:)])
                {
                    cell.badgeLayer = [provider badgeLayerForItem:item];
                    if (cell.badgeLayer)
                    {
                        break;
                    }
                }
            }
        }
        
        return cell;
    }
    
    return nil;
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

-(void)reloadItem:(NSNotification*)notification
{
    id<XPItem> item = (id<XPItem>)notification.userInfo[@"item"];
    if (item)
    {
        NSUInteger itemIndex = [[_collection allItems] indexOfObject:item];
        if (itemIndex != NSNotFound && [_gridView.indexesForVisibleCells containsIndex:itemIndex])
        {
            [self performBlockOnMainThread:^{
                [_gridView reloadCellsAtIndexes:[NSIndexSet indexSetWithIndex:itemIndex]];
            }];
        }
    }
}

-(void)awakeFromNib
{
    [XPExposureService collectionManager:_collectionManager itemCollectionViewController:self];
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
    
    [collections bk_each:^(id<XPItemCollection> collection)
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
    
    [items bk_each:^(id<XPItem> item)
    {
        [collection moveItem:item withCompletion:nil];
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
    
    id<XPItemCollection> collection = _collection;
    
    for (NSString *type in [NSImage imagePasteboardTypes])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        NSData *data = [pboard dataForType:type];
        
        NSString *fileName = (fileURL && fileURL.pathExtension) ? fileURL.pathExtension : @"Copied image.png";
        
        if (data)
        {
            NSURL *destURL = [collection.path URLByAppendingPathComponent:fileName];
            CFStringRef uti = [destURL imageUTI];
            
            if ([data writeImage:destURL withUTI:uti])
            {
                return YES;
            }
        }
    }
    
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
    
    for (NSString *type in [NSImage imagePasteboardTypes])
    {
        NSData *data = [pboard dataForType:type];
        return data != nil;
    }
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] && [collection respondsToSelector:@selector(path)])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        
        BOOL isDir;
        return [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path isDirectory:&isDir] && !isDir;
    }
    else if ([[pboard types] containsObject:NSTIFFPboardType])
    {
        return [NSURL URLFromPasteboard:pboard] != NULL;
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
