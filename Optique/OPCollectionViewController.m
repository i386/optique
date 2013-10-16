//
//  OPAlbumViewController.m
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCollectionViewController.h"

#import "OPPhotoCollectionViewController.h"
#import "OPAlbumScanner.h"
#import "OPImagePreviewService.h"
#import "OPDeleteAlbumSheetController.h"
#import "OPPhotoAlbum.h"
#import "OPGridViewCell.h"
#import "NSColor+Optique.h"
#import "CATextLayer+EmptyCollection.h"
#import "OPLocalPhoto.h"
#import "OPPlaceHolderViewController.h"

@interface OPCollectionViewController ()

@property (strong) OPDeleteAlbumSheetController *deleteAlbumSheetController;
@property (strong) NSPredicate *predicate;
@property (strong) NSMutableArray *sharingMenuItems;
@property (strong) NSString *viewTitle;
@property (strong) NSString *emptyMessage;
@property (strong) OPPlaceHolderViewController *placeHolderViewController;
@property (assign) BOOL shouldDisplayViewForNoGridItems;

@end

@implementation OPCollectionViewController

-(id)initWithPhotoManager:(XPPhotoManager *)photoManager title:(NSString *)title emptyMessage:(NSString*)emptyMessage icon:(NSImage *)icon collectionPredicate:(NSPredicate *)predicate
{
    self = [super initWithNibName:@"OPCollectionViewController" bundle:nil];
    if (self)
    {
        _photoManager = photoManager;
        _viewTitle = title;
        _emptyMessage = emptyMessage;
        _predicate = predicate;
        _placeHolderViewController = [[OPPlaceHolderViewController alloc] initWithText:emptyMessage image:icon];
    }
    return self;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumAdded:) name:XPPhotoManagerDidAddCollection object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumDeleted:) name:XPPhotoManagerDidDeleteCollection object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumUpdated:) name:XPPhotoManagerDidUpdateCollection object:nil];
    
    [OPExposureService photoManager:_photoManager collectionViewController:self];
    
    [_headingLine setBorderWidth:2];
    [_headingLine setBorderColor:[NSColor colorWithCalibratedRed:0.83 green:0.83 blue:0.83 alpha:1.00]];
    [_headingLine setBoxType:NSBoxCustom];
    
    _titleLabel.stringValue = _viewTitle;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidAddCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidDeleteCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidUpdateCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumScannerDidFindAlbumsNotification object:nil];
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
    NSArray *collections = [_photoManager allCollectionsForIndexSet:indexes];
    
    //TODO: check menu for XPMenuItems and run predicate to hide
    
    __block BOOL allSelectedAreLocal = YES;
    [collections each:^(id<XPPhotoCollection> sender) {
        if (allSelectedAreLocal && [sender collectionType] != kPhotoCollectionLocal)
        {
            allSelectedAreLocal = NO;
        }
    }];
    
    __block BOOL allSelectedAreNotLocal = YES;
    [collections each:^(id<XPPhotoCollection> sender) {
        if (allSelectedAreNotLocal && [sender collectionType] != kPhotoCollectionLocal)
        {
            allSelectedAreNotLocal = NO;
        }
    }];
    
    if (allSelectedAreLocal)
    {
        [_deleteAlbumMenuItem setHidden:NO];
        [_ejectMenuItem setHidden:YES];
    }
    else if (allSelectedAreNotLocal)
    {
        [_deleteAlbumMenuItem setHidden:YES];
        [_ejectMenuItem setHidden:NO];
    }
    else
    {
        [_deleteAlbumMenuItem setHidden:YES];
        [_ejectMenuItem setHidden:YES];
    }
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

-(void)deleteAlbumsAtIndexes:(NSIndexSet*)indexes
{
    _deleteAlbumSheetController = [[OPDeleteAlbumSheetController alloc] initWithPhotoAlbums:[_photoManager allCollectionsForIndexSet:indexes] photoManager:_photoManager];
    
    NSString *alertMessage;
    if (indexes.count > 1)
    {
        alertMessage = [NSString stringWithFormat:@"Do you want to delete the %lu selected albums?", indexes.count];
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

- (void)reloadData
{
    [self willChangeValueForKey:@"numberOfItems"];
    [_gridView reloadData];
    [self didChangeValueForKey:@"numberOfItems"];
}

-(void)albumAdded:(NSNotification*)notification
{
    id<XPPhotoCollection> collection = [notification userInfo][@"collection"];
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
    NSArray *filteredCollections = [_photoManager.allCollections filteredArrayUsingPredicate:_predicate];
    id collection = filteredCollections[index];
    [self.controller pushViewController:[[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:collection photoManager:_photoManager]];
}

-(void)showCollectionWithTitle:(NSString *)title
{
    id collection = [[_photoManager.allCollections filteredArrayUsingPredicate:_predicate] match:^BOOL(id<XPPhotoCollection> obj) {
        return [[obj title] isEqualToString:title];
    }];
    
    if (collection)
    {
        [self.controller pushViewController:[[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:collection photoManager:_photoManager]];
    }
}

-(NSUInteger)numberOfItems
{
    return [_photoManager.allCollections filteredArrayUsingPredicate:_predicate].count;
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
    OPGridViewCell *item = [[OPGridViewCell alloc] init];
    
    NSArray *filteredCollections = [_photoManager.allCollections filteredArrayUsingPredicate:_predicate];
    id<XPPhotoCollection> collection = filteredCollections[index];
    item.representedObject = collection;
    item.title = collection.title;
    item.view.toolTip = collection.title;
    
    id<XPPhoto> coverPhoto = [collection coverPhoto];
    if (coverPhoto)
    {
        OPGridViewCell * __weak weakItem = item;
        
        item.image = [[OPImagePreviewService defaultService] previewImageWithPhoto:coverPhoto loaded:^(NSImage *image) {
              [self performBlockOnMainThread:^{
                   weakItem.image = image;
               }];
          }];
    }
    else
    {
        item.image = [NSImage imageNamed:@"empty-album"];
    }
    
    if (!item.badgeLayer)
    {
        //Get badge layer from exposure
        for (id<XPPhotoCollectionProvider> provider in [OPExposureService photoCollectionProviders])
        {
            if ([provider respondsToSelector:@selector(badgeLayerForCollection:)])
            {
                item.badgeLayer = [provider badgeLayerForCollection:collection];
                if (item.badgeLayer)
                {
                    break;
                }
            }
        }
    }
    
    return item;
}

-(NSView *)viewForNoItemsInGridView:(OEGridView *)gridView
{
    _placeHolderViewController.view.frame = gridView.frame;
    return _placeHolderViewController.view;
}

@end
