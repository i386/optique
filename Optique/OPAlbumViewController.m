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
#import "OPCamera.h"
#import "OPNavigationTitle.h"
#import "OPPhotoAlbum.h"
#import "OPGridViewCell.h"

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
        
        _albumPredicate =[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject isKindOfClass:[OPPhotoAlbum class]];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraAdded:) name:OPCameraServiceDidAddCamera object:nil];
    
    [OPExposureService photoManager:_photoManager collectionViewController:self];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidAddCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidDeleteCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidUpdateCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumScannerDidFindAlbumsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumScannerDidFinishScanNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPNavigationTitleFilterDidChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPCameraServiceDidAddCamera object:nil];
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
    return nil;
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
        if (allSelectedAreLocal && !sender.isStoredOnFileSystem)
        {
            allSelectedAreLocal = NO;
        }
    }];
    
    __block BOOL allSelectedAreNotLocal = YES;
    [collections each:^(id<XPPhotoCollection> sender) {
        if (allSelectedAreNotLocal && sender.isStoredOnFileSystem)
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

- (IBAction)revealInFinder:(NSMenuItem*)sender
{
    NSIndexSet *indexes = (NSIndexSet*)sender.representedObject;
    NSMutableArray *urls = [NSMutableArray array];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop)
    {
        id collection = _photoManager.allCollections[index];
        if ([collection respondsToSelector:@selector(path)])
        {
            [urls addObject:[collection path]];
        }
    }];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:urls];
}

-(void)deleteSelected
{
    NSIndexSet *indexes = [_gridView indexesForSelectedCells];
    [self deleteAlbumsAtIndexes:indexes];
}

- (IBAction)deleteAlbum:(NSMenuItem*)sender
{
    NSIndexSet *indexes = (NSIndexSet*)sender.representedObject;
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

- (IBAction)ejectCamera:(id)sender
{
    NSIndexSet *indexes = _ejectMenuItem.representedObject;
    NSArray *cameras = [_photoManager allCollectionsForIndexSet:indexes];
    
    [cameras each:^(OPCamera *camera) {
        [camera requestEject];
    }];
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
    return @"Optique";
}

-(void)cameraAdded:(NSNotification*)notification
{
    _currentPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ![_albumPredicate evaluateWithObject:evaluatedObject];
    }];
    
    [self.controller popToRootViewController];
    [_gridView reloadData];
}

-(void)filterChanged:(NSNotification*)notification
{
    NSNumber *segment = [notification userInfo][@"segment"];
    switch (segment.integerValue) {
        case OPNavigationTitleFilterAlbums:
            _currentPredicate = _albumPredicate;
            break;
        case OPNavigationTitleFilterDevices:
            _currentPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return ![_albumPredicate evaluateWithObject:evaluatedObject];
            }];
            break;
    }
    
    //If the filter is changed, pop back to this view.
    [self.controller popToRootViewControllerWithNoAnimation];
    
    //TODO: only reload if there has been a change
    [_gridView reloadData];
}

-(void)albumAdded:(NSNotification*)notification
{
    XPPhotoManager *photoManager = [notification userInfo][@"photoManager"];
    
    if ([photoManager isEqual:_photoManager])
    {
        id<XPPhotoCollection> collection = [notification userInfo][@"collection"];
        if (collection)
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
        XPPhotoManager *photoManager = [notification userInfo][@"photoManager"];
        
        if ([photoManager isEqual:_photoManager])
        {
            [_gridView reloadData];
        }
    }];
}

-(void)albumDeleted:(NSNotification*)notification
{
    [self performBlockOnMainThread:^{
        XPPhotoManager *photoManager = [notification userInfo][@"photoManager"];
        
        if ([photoManager isEqual:_photoManager])
        {
            [_gridView reloadData];
            
            //If the album is deleted pop back to the root controller
            [self.controller popToRootViewController];
        }
    }];
}

-(void)albumsFinishedLoading:(NSNotification*)notification
{
    [self performBlockOnMainThread:^
    {
        XPPhotoManager *photoManager = [notification userInfo][@"photoManager"];
        
        if ([photoManager isEqual:_photoManager])
        {
            [self.controller updateNavigation];
        }
    }];
}

-(void)gridView:(OEGridView *)gridView doubleClickedCellForItemAtIndex:(NSUInteger)index
{
    NSArray *filteredCollections = [_photoManager.allCollections filteredArrayUsingPredicate:_currentPredicate];
    OPPhotoAlbum *photoAlbum = filteredCollections[index];
    [self.controller pushViewController:[[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:photoAlbum photoManager:_photoManager]];
}

-(NSUInteger)numberOfItemsInGridView:(OEGridView *)gridView
{
    NSArray *filteredCollections = [_photoManager.allCollections filteredArrayUsingPredicate:_currentPredicate];
    return filteredCollections.count;
}

- (OEGridViewCell *)gridView:(OEGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    OPGridViewCell *item = (OPGridViewCell *)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
    if (!item) {
        item = (OPGridViewCell *)[gridView dequeueReusableCell];
    }
    if (!item) {
        item = [[OPGridViewCell alloc] init];
    }
    
    NSArray *filteredCollections = [_photoManager.allCollections filteredArrayUsingPredicate:_currentPredicate];
    OPPhotoAlbum *album = filteredCollections[index];
    item.representedObject = album;
    item.title = album.title;
    item.view.toolTip = album.title;
    
    NSArray *allPhotos = album.allPhotos;
    if (allPhotos.count > 0)
    {
        id<XPPhoto> photo = allPhotos[0];
        
        OPGridViewCell * __weak weakItem = item;
        OPPhotoAlbum * __weak weakAlbum = album;
        
        item.image = [[OPImagePreviewService defaultService] previewImageWithPhoto:photo loaded:^(NSImage *image) {
              [self performBlockOnMainThreadAndWaitUntilDone:^
               {
                   if (weakItem.representedObject == weakAlbum)
                   {
                       weakItem.image = image;
                       [weakItem.view setNeedsDisplay:YES];
                   }
               }];
          }];
    }
    else
    {
        item.image = [NSImage imageNamed:@"empty-album"];
    }
    
    return item;
}

@end
