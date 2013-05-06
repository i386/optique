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

@interface OPAlbumViewController () {
    OPDeleteAlbumSheetController *_deleteAlbumSheetController;
}
@end

@implementation OPAlbumViewController

-(id)initWithPhotoManager:(XPPhotoManager *)photoManager
{
    self = [super initWithNibName:@"OPAlbumViewController" bundle:nil];
    if (self)
    {
        _photoManager = photoManager;
    }
    return self;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumAdded:) name:XPPhotoManagerDidAddCollection object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumDeleted:) name:XPPhotoManagerDidDeleteCollection object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumUpdated:) name:XPPhotoManagerDidUpdateCollection object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumsFinishedLoading:) name:OPAlbumScannerDidFinishScanNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidAddCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidDeleteCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidUpdateCollection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumScannerDidFindAlbumsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumScannerDidFinishScanNotification object:nil];
}

-(void)loadView
{
    [super loadView];
    [_gridView setAllowsMultipleSelection:YES];
    [[_gridView enclosingScrollView] setDrawsBackground:NO];
    
    [OPExposureService collectionViewController:self];
}

-(void)showView
{
    [_gridView reloadData];
}

-(void)menuNeedsUpdate:(NSMenu *)menu
{
    NSIndexSet *indexes = _gridView.selectedIndexes;
    NSArray *collections = [_photoManager allCollectionsForIndexSet:indexes];
    
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
        [_revealInFinderMenuItem setHidden:NO];
        [_deleteAlbumMenuItem setHidden:NO];
        [_ejectMenuItem setHidden:YES];
    }
    else if (allSelectedAreNotLocal)
    {
        [_revealInFinderMenuItem setHidden:YES];
        [_deleteAlbumMenuItem setHidden:YES];
        [_ejectMenuItem setHidden:NO];
    }
    else
    {
        [_revealInFinderMenuItem setHidden:YES];
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
    OPPhotoAlbum *photoAlbum = (OPPhotoAlbum*)_photoManager.allCollections[index];
    [self.controller pushViewController:[[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:photoAlbum photoManager:_photoManager]];
}

-(NSString *)viewTitle
{
    return @"Optique";
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
    return _photoManager.allCollections.count;
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section
{
    OPPhotoGridItemView *item = [gridView dequeueReusableItemWithIdentifier:(NSString*)OPPhotoGridViewReuseIdentifier];
    if (item == nil) {
        item = [[OPPhotoGridItemView alloc] initWithLayout:nil reuseIdentifier:(NSString*)OPPhotoGridViewReuseIdentifier];
    }
    
    OPPhotoAlbum *album = _photoManager.allCollections[index];
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
    item.gridView = (OPPhotoGridView*)gridView;
    
    return item;
}

@end
