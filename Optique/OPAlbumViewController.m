//
//  OPAlbumViewController.m
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAlbumViewController.h"

#import "OPPhotoCollectionViewController.h"
#import "OPAlbumScanner.h"
#import "OPImagePreviewService.h"
#import "OPDeleteAlbumSheetController.h"
#import "OPNavigationTitle.h"
#import "OPPhotoAlbum.h"
#import "OPGridViewCell.h"
#import "NSColor+Optique.h"
#import "CATextLayer+EmptyCollection.h"
#import "OPLocalPhoto.h"

@interface OPAlbumViewController ()

@property (strong) OPDeleteAlbumSheetController *deleteAlbumSheetController;
@property (strong) NSPredicate *currentPredicate;
@property (strong) NSPredicate *albumPredicate;
@property (strong) NSMutableArray *sharingMenuItems;

@end

@implementation OPAlbumViewController

-(id)initWithPhotoManager:(XPPhotoManager *)photoManager
{
    self = [super initWithNibName:@"OPAlbumViewController" bundle:nil];
    if (self)
    {
        _photoManager = photoManager;
        
        _albumPredicate =[NSPredicate predicateWithBlock:^BOOL(id<XPPhotoCollection> evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject collectionType] == kPhotoCollectionLocal || [evaluatedObject collectionType] == kPhotoCollectionOther;
        }];
        
        _currentPredicate = _albumPredicate;
    }
    return self;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumAdded:) name:XPPhotoManagerDidAddCollection object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumDeleted:) name:XPPhotoManagerDidDeleteCollection object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumUpdated:) name:XPPhotoManagerDidUpdateCollection object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumsFinishedLoading:) name:OPAlbumScannerDidFinishScanNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterChanged:) name:OPNavigationTitleFilterDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraAdded:) name:@"OPCameraServiceDidAddCamera" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFilterActivated:) name:OPNavigationSearchFilterDidChange object:nil];
    
    
    [OPExposureService photoManager:_photoManager collectionViewController:self];
    
    [_headingLine setBorderWidth:2];
    [_headingLine setBorderColor:[NSColor colorWithCalibratedRed:0.83 green:0.83 blue:0.83 alpha:1.00]];
    [_headingLine setBoxType:NSBoxCustom];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidAddCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidDeleteCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidUpdateCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumScannerDidFindAlbumsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumScannerDidFinishScanNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPNavigationTitleFilterDidChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OPCameraServiceDidAddCamera" object:nil];
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

-(NSString *)viewTitle
{
    return @"";
}

-(void)cameraAdded:(NSNotification*)notification
{
    _currentPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ![_albumPredicate evaluateWithObject:evaluatedObject];
    }];
    
    [self.controller popToRootViewController];
    [_gridView reloadData];
}

-(void)searchFilterActivated:(NSNotification*)notification
{
    NSString *value = notification.userInfo[@"value"];
    
    if (![value isEqualToString:@""])
    {
        _currentPredicate = [NSPredicate predicateWithBlock:^BOOL(id<XPPhotoCollection> collection, NSDictionary *bindings) {
            return [_albumPredicate evaluateWithObject:collection] && [[NSPredicate predicateWithFormat:@"self.title contains[cd] %@", value] evaluateWithObject:collection];
        }];
    }
    else
    {
        _currentPredicate = _albumPredicate;
    }
    
    [_gridView reloadData];
}

-(void)filterChanged:(NSNotification*)notification
{
    NSNumber *isAlbumView = [notification userInfo][@"isAlbumView"];
    
    if (isAlbumView.boolValue)
    {
        _currentPredicate = _albumPredicate;
    }
    else
    {
        _currentPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return ![_albumPredicate evaluateWithObject:evaluatedObject];
        }];
    }
    
    //If the filter is changed, pop back to this view.
    [self.controller popToRootViewControllerWithNoAnimation];
    
    //TODO: only reload if there has been a change
    [_gridView reloadData];
}

-(void)albumAdded:(NSNotification*)notification
{
    id<XPPhotoCollection> collection = [notification userInfo][@"collection"];
    if (collection)
    {
        [self performBlockOnMainThread:^{
            [_gridView reloadData];
        }];
    }
}

-(void)albumUpdated:(NSNotification*)notification
{
    [self performBlockOnMainThread:^{
        [_gridView reloadData];
    }];
}

-(void)albumDeleted:(NSNotification*)notification
{
    [self performBlockOnMainThread:^{
        [_gridView reloadData];
        
        //If the album is deleted pop back to the root controller
        [self.controller popToRootViewController];
    }];
}

-(void)albumsFinishedLoading:(NSNotification*)notification
{
    [self performBlockOnMainThread:^
    {
        [self.controller updateNavigation];
    }];
}

-(void)gridView:(OEGridView *)gridView doubleClickedCellForItemAtIndex:(NSUInteger)index
{
    NSArray *filteredCollections = [_photoManager.allCollections filteredArrayUsingPredicate:_currentPredicate];
    OPPhotoAlbum *photoAlbum = filteredCollections[index];
    [self.controller pushViewController:[[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:photoAlbum photoManager:_photoManager]];
}

-(NSUInteger)numberOfItems
{
    return [_photoManager.allCollections filteredArrayUsingPredicate:_currentPredicate].count;
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
    
    NSArray *filteredCollections = [_photoManager.allCollections filteredArrayUsingPredicate:_currentPredicate];
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

@end
