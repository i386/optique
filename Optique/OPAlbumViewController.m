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
#import "OPPhotoGridItemView.h"
#import "OPImagePreviewService.h"
#import "OPDeleteAlbumSheetController.h"
#import "OPCamera.h"
#import "OPNavigationTitle.h"
#import "OPPhotoAlbum.h"

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
    [_gridView setAllowsMultipleSelection:YES];
    [_gridView.enclosingScrollView setDrawsBackground:NO];
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
    return _gridView.selectedIndexes;
}

-(void)showView
{
    [_gridView reloadData];
}

-(void)menuNeedsUpdate:(NSMenu *)menu
{
    NSIndexSet *indexes = _gridView.selectedIndexes;
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

- (IBAction)deleteAlbum:(NSMenuItem*)sender
{
    NSIndexSet *index = (NSIndexSet*)sender.representedObject;
    
    _deleteAlbumSheetController = [[OPDeleteAlbumSheetController alloc] initWithPhotoAlbums:[_photoManager allCollectionsForIndexSet:index] photoManager:_photoManager];
    
    NSString *alertMessage;
    if (index.count > 1)
    {
        alertMessage = [NSString stringWithFormat:@"Do you want to delete the %lu selected albums?", index.count];
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

- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    NSArray *filteredCollections = [_photoManager.allCollections filteredArrayUsingPredicate:_currentPredicate];
    OPPhotoAlbum *photoAlbum = filteredCollections[index];
    [self.controller pushViewController:[[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:photoAlbum photoManager:_photoManager]];
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

- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    NSArray *filteredCollections = [_photoManager.allCollections filteredArrayUsingPredicate:_currentPredicate];
    return filteredCollections.count;
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section
{
    OPPhotoGridItemView *item = [gridView dequeueReusableItemWithIdentifier:(NSString*)OPPhotoGridViewReuseIdentifier];
    if (item == nil) {
        item = [[OPPhotoGridItemView alloc] initWithLayout:nil reuseIdentifier:(NSString*)OPPhotoGridViewReuseIdentifier];
    }
    
    NSArray *filteredCollections = [_photoManager.allCollections filteredArrayUsingPredicate:_currentPredicate];
    OPPhotoAlbum *album = filteredCollections[index];
    item.representedObject = album;
    
    NSArray *allPhotos = album.allPhotos;
    
    if (allPhotos.count > 0)
    {
        id<XPPhoto> photo = allPhotos[0];
        
        CNGridViewItem * __weak weakItem = item;
        OPPhotoAlbum * __weak weakAlbum = album;
        
        item.itemImage = [[OPImagePreviewService defaultService] previewImageWithPhoto:photo loaded:^(NSImage *image)
        {
            [self performBlockOnMainThreadAndWaitUntilDone:^
            {
                if (weakItem.representedObject == weakAlbum)
                {
                    weakItem.itemImage = image;
                    [weakItem setNeedsDisplay:YES];
                }
            }];
        }];
    }
    else
    {
        item.itemImage = [NSImage imageNamed:@"empty-album"];
    }
    item.itemTitle = album.title;
    item.toolTip = album.title;
    item.gridView = (OPPhotoGridView*)gridView;
    
    return item;
}

@end
