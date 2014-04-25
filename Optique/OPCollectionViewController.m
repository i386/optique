//
//  OPAlbumViewController.m
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "OPCollectionViewController.h"

#import "OPItemCollectionViewController.h"
#import "OPRenameAlbumWindowController.h"
#import "OPItemPreviewManager.h"
#import "OPDeleteAlbumSheetController.h"
#import "OPGridViewCell.h"
#import "NSColor+Optique.h"
#import "OPLocalItem.h"
#import "OPPlaceHolderViewController.h"
#import "NSURL+Renamer.h"

@interface ItemCollectionPasteboardWriting : NSObject<NSPasteboardWriting>

@property (weak) id<XPItemCollection> collection;

@end

@implementation ItemCollectionPasteboardWriting

-(NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    static NSArray *writableTypes = nil;
    if (!writableTypes)
    {
        writableTypes = @[(NSString *)kUTTypeURL];
    }
    return writableTypes;
}

-(id)pasteboardPropertyListForType:(NSString *)type
{
    id collection = _collection;
    if ([type isEqualToString:(NSString *)kUTTypeURL] && [collection respondsToSelector:@selector(path)])
    {
        return [[collection path] pasteboardPropertyListForType:(NSString *)kUTTypeURL];
    }
    return nil;
}

@end

@interface OPCollectionViewController ()

@property (strong) OPDeleteAlbumSheetController *deleteAlbumSheetController;
@property (strong) OPRenameAlbumWindowController *renameAlbumWindowController;
@property (strong) NSMutableArray *sharingMenuItems;
@property (strong) NSString *viewTitle;
@property (strong) NSString *emptyMessage;
@property (strong) OPPlaceHolderViewController *placeHolderViewController;
@property (assign) BOOL shouldDisplayViewForNoGridItems;

@end

@implementation OPCollectionViewController

-(id)initWithCollectionManager:(XPCollectionManager *)collectionManager title:(NSString *)title emptyMessage:(NSString*)emptyMessage icon:(NSImage *)icon collectionPredicate:(NSPredicate *)predicate
{
    self = [super initWithNibName:@"OPCollectionViewController" bundle:nil];
    if (self)
    {
        _collectionManager = collectionManager;
        _viewTitle = title;
        _emptyMessage = emptyMessage;
        _predicate = predicate;
        _placeHolderViewController = [[OPPlaceHolderViewController alloc] initWithText:emptyMessage image:icon];
    }
    return self;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumAdded:) name:XPCollectionManagerDidAddCollection object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumDeleted:) name:XPCollectionManagerDidDeleteCollection object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumUpdated:) name:XPCollectionManagerDidUpdateCollection object:nil];
    
    [XPExposureService collectionManager:_collectionManager collectionViewController:self];
    
    _titleLabel.stringValue = _viewTitle;
    self.gridView.disableCellReuse = YES;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPCollectionManagerDidAddCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPCollectionManagerDidDeleteCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPCollectionManagerDidUpdateCollection object:nil];
}

-(void)loadView
{
    [super loadView];
}

-(NSMenu *)contextMenu
{
    return _albumItemContextMenu;
}

-(NSWindow *)window
{
    return self.view.window;
}

-(NSIndexSet *)selectedItems
{
    return _gridView.selectionIndexes;
}

-(void)showView
{
    [_gridView reloadData];
    [[_gridView enclosingScrollView] setDrawsBackground:NO];
}

-(void)menuNeedsUpdate:(NSMenu *)menu
{
    NSIndexSet *indexes = _gridView.indexesForSelectedCells;
    NSArray *collections = [_collectionManager allCollectionsForIndexSet:indexes];
    
    //TODO: check menu for XPMenuItems and run predicate to hide
    
    __block BOOL allSelectedAreLocal = YES;
    [collections bk_each:^(id<XPItemCollection> sender) {
        if (allSelectedAreLocal && [sender collectionType] != XPItemCollectionLocal)
        {
            allSelectedAreLocal = NO;
        }
    }];
    
    __block BOOL allSelectedAreNotLocal = YES;
    [collections bk_each:^(id<XPItemCollection> sender) {
        if (allSelectedAreNotLocal && [sender collectionType] != XPItemCollectionLocal)
        {
            allSelectedAreNotLocal = NO;
        }
    }];
    
    if (allSelectedAreLocal)
    {
        [_deleteAlbumMenuItem setHidden:NO];
        
        NSIndexSet *indexes = self.gridView.selectionIndexes;
        
        if (indexes.count == 1)
        {
            [_renameAlbumMenuItem setHidden:NO];
        }
    }
    else
    {
        [_deleteAlbumMenuItem setHidden:YES];
        [_renameAlbumMenuItem setHidden:YES];
    }
    
    [XPExposureService menuVisiblity:_albumItemContextMenu items:collections];
}

-(void)deleteSelected
{
    NSIndexSet *indexes = [_gridView indexesForSelectedCells];
    [self deleteAlbumsAtIndexes:indexes];
}

- (IBAction)deleteAlbum:(NSMenuItem*)sender
{
    NSIndexSet *indexes = [_gridView selectionIndexes];
    [self deleteAlbumsAtIndexes:indexes];
}

- (IBAction)renameAlbum:(id)sender
{
    NSUInteger index = [[_gridView selectionIndexes] lastIndex];
    id<XPItemCollection> collection = _collectionManager.allCollections[index];
    if (collection)
    {
        _renameAlbumWindowController = [[OPRenameAlbumWindowController alloc] initWithCollectionManager:_collectionManager collection:collection parentController:self];
        
        [self.window beginSheet:_renameAlbumWindowController.window completionHandler:^(NSModalResponse returnCode) {
            NSLog(@"return code %ld", (long)returnCode);
        }];
    }
}

-(void)deleteAlbumsAtIndexes:(NSIndexSet*)indexes
{
    _deleteAlbumSheetController = [[OPDeleteAlbumSheetController alloc] initWithCollections:[_collectionManager allCollectionsForIndexSet:indexes] collectionManager:_collectionManager parentController:self];
    
    NSString *alertMessage;
    if (indexes.count > 1)
    {
        alertMessage = [NSString stringWithFormat:@"Do you want to delete the %lu selected albums?", indexes.count];
    }
    else
    {
        id<XPItemCollection> album = [_deleteAlbumSheetController.albums lastObject];
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

- (void)reloadData
{
    [self willChangeValueForKey:@"numberOfItems"];
    [_gridView reloadData];
    [self didChangeValueForKey:@"numberOfItems"];
}

-(void)albumAdded:(NSNotification*)notification
{
    id<XPItemCollection> collection = [notification userInfo][@"collection"];
    if (collection)
    {
        [self performBlockOnMainThread:^{
            [self reloadData];
        }];
    }
}

-(void)albumUpdated:(NSNotification*)notification
{
    [self performBlockOnMainThread:^{
        [self reloadData];
    }];
}

-(void)albumDeleted:(NSNotification*)notification
{
    [self performBlockOnMainThread:^{
        [self reloadData];
        
        //If the album is deleted pop back to the root controller
        [self.controller popToRootViewController];
    }];
}

-(void)gridView:(OEGridView *)gridView doubleClickedCellForItemAtIndex:(NSUInteger)index
{
    NSArray *filteredCollections = [_collectionManager.allCollections filteredArrayUsingPredicate:_predicate];
    id<XPItemCollection> collection = filteredCollections[index];
    [self.controller pushViewController:[self viewForCollection:collection collectionManager:_collectionManager]];
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

-(NSViewController*)viewForCollection:(id<XPItemCollection>)collection collectionManager:(XPCollectionManager*)collectionManager
{
    return [[OPItemCollectionViewController alloc] initWithIemCollection:collection collectionManager:collectionManager];
}

-(void)showCollectionWithTitle:(NSString *)title
{
    id collection = [[_collectionManager.allCollections filteredArrayUsingPredicate:_predicate] bk_match:^BOOL(id<XPItemCollection> obj) {
        return [[obj title] isEqualToString:title];
    }];
    
    if (collection)
    {
        [self.controller pushViewController:[self viewForCollection:collection collectionManager:_collectionManager]];
    }
}

-(NSUInteger)numberOfItems
{
    return [_collectionManager.allCollections filteredArrayUsingPredicate:_predicate].count;
}

-(NSUInteger)numberOfItemsInGridView:(OEGridView *)gridView
{
    return [self numberOfItems];
}

-(NSMenu *)gridView:(OEGridView *)gridView menuForItemsAtIndexes:(NSIndexSet *)indexes
{
    return _albumItemContextMenu;
}

- (OEGridViewCell *)gridView:(OEGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    OPGridViewCell *cell = (OPGridViewCell *)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
    if (!cell)
    {
        cell = (OPGridViewCell *)[gridView dequeueReusableCell];
    }
    
    if (!cell)
    {
        cell = [[OPGridViewCell alloc] init];
    }
    
    NSArray *filteredCollections = [_collectionManager.allCollections filteredArrayUsingPredicate:_predicate];
    
    id<XPItemCollection> collection = filteredCollections[index];
    cell.title = collection.title;
    cell.view.toolTip = collection.title;
    
    id<XPItem> item = [collection coverItem];
    if (item)
    {
        cell.representedObject = item;
        
        id<XPItem> __weak weakItem = item;
        OPGridViewCell * __weak weakCell = cell;
        
        [[OPItemPreviewManager defaultManager] previewItem:item size:_gridView.itemSize loaded:^(NSImage *image) {
            [self performBlockOnMainThread:^
             {
                 if (weakItem == weakCell.representedObject)
                 {
                     weakCell.image = image;
                 }
             }];
        }];
    }
    
    if (!cell.badgeLayer)
    {
        //Get badge layer from exposure
        for (id<XPItemCollectionProvider> provider in [XPExposureService itemCollectionProviders])
        {
            if ([provider respondsToSelector:@selector(badgeLayerForCollection:)])
            {
                cell.badgeLayer = [provider badgeLayerForCollection:collection];
                if (cell.badgeLayer)
                {
                    break;
                }
            }
        }
    }
    
    return cell;
}

-(NSView *)viewForNoItemsInGridView:(OEGridView *)gridView
{
    _placeHolderViewController.view.frame = gridView.frame;
    return _placeHolderViewController.view;
}

- (NSDragOperation)gridView:(OEGridView *)gridView validateDrop:(id<NSDraggingInfo>)sender
{
    return [self isDirectoryDrop:sender] ? NSDragOperationCopy : NSDragOperationNone;
}
- (NSDragOperation)gridView:(OEGridView *)gridView draggingUpdated:(id<NSDraggingInfo>)sender
{
    return [self isDirectoryDrop:sender] ? NSDragOperationCopy : NSDragOperationNone;
}

- (BOOL)gridView:(OEGridView *)gridView acceptDrop:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path isDirectory:&isDir] && isDir)
        {
            NSString *fileName = [fileURL lastPathComponent];
            NSURL *destURL = [_collectionManager path];
            destURL = [[destURL URLByAppendingPathComponent:fileName] URLWithUniqueNameIfExistsAtParent];
            
            NSError *error;
            [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:destURL error:&error];
            
            return error ? NO : YES;
        }
    }
    
    return NO;
}

-(BOOL)isDirectoryDrop:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        
        BOOL isDir;
        return [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path isDirectory:&isDir] && isDir;
    }
    return NO;
}

-(id<NSPasteboardWriting>)gridView:(OEGridView *)gridView pasteboardWriterForIndex:(NSInteger)index
{
    ItemCollectionPasteboardWriting *photoCollectionPasteboardWriting = [[ItemCollectionPasteboardWriting alloc] init];
    photoCollectionPasteboardWriting.collection = [_collectionManager.allCollections objectAtIndex:index];
    return photoCollectionPasteboardWriting;
}

-(NSArray *)fileTypesForDraggingOperation:(OEGridView *)gridView
{
    NSMutableSet *extensions = [NSMutableSet set];
    for (id<XPItemCollection> collection in [_collectionManager allCollectionsForIndexSet:_gridView.selectionIndexes])
    {
        for (id<XPItem> item in [collection allItems])
        {
            [extensions addObject:[item.url pathExtension]];
        }
    }
    return [extensions allObjects];
}

-(NSArray *)namesOfPromisedFilesDroppedForGrid:(OEGridView *)gridView atDestination:(NSURL *)dropDestination
{
    NSMutableArray *names = [NSMutableArray array];
    for (id<XPItemCollection> collection in [_collectionManager allCollectionsForIndexSet:_gridView.selectionIndexes])
    {
        NSString *filename = [collection.path lastPathComponent];
        [names addObject:filename];
        
        [self performBlockInBackground:^{
            NSURL *destinationURL = [[dropDestination URLByAppendingPathComponent:filename] URLWithUniqueNameIfExistsAtParent];
            [[[NSFileManager alloc] init] copyItemAtURL:collection.path toURL:destinationURL error:nil];
        }];
    }
    return names;
}

- (NSDragOperation)gridView:(OEGridView *)gridView draggingSourceOperationMaskForLocal:(BOOL)flag
{
    return flag ? NSDragOperationCopy : NSDragOperationNone;
}

-(NSArray *)collections
{
    return [_collectionManager.allCollections filteredArrayUsingPredicate:_predicate];
}

@end
