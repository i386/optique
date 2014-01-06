//
//  OPHistoryPeekViewController.m
//  Optique
//
//  Created by James Dumay on 4/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPHistoryPeekViewController.h"
#import "OPImagePreviewService.h"
#import "OPPhotoViewController.h"
#import "OPPhotoCollectionViewController.h"
#import "OPGridViewCell.h"
#import "NSWindow+FullScreen.h"

@interface OPHistoryPeekViewController ()

@end

@implementation OPHistoryPeekViewController

-initWithItems:(NSArray*)items navigationController:(OPNavigationController*)navigationController;
{
    self = [super initWithNibName:@"OPHistoryPeekViewController" bundle:nil];
    if (self) {
        _items = items;
        _navigationController = navigationController;
    }
    return self;
}

-(bool)showable
{
    return !self.view.window.isFullscreen && _items.count > 1;
}

-(void)gridView:(OEGridView *)gridView clickedCellForItemAtIndex:(NSUInteger)index
{
    id<XPItem> item = _items[index];
    
    OPNavigationViewController *controller;
    if (![item respondsToSelector:@selector(collection)])
    {
        id<XPPhotoCollection> collection = (id<XPPhotoCollection>)item;
        controller = [[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:collection photoManager:[collection photoManager]];
    }
    else
    {
        controller = [[OPPhotoViewController alloc] initWithPhotoCollection:[item collection] photo:_items[index]];
    }
    
    [_navigationController popToPreviousViewController];
    [_navigationController pushViewController:controller];
    
    NSRect cellRect = [_gridView rectForCellAtIndex:index];
    
    NSPoint pointToScrollTo = NSMakePoint(cellRect.origin.x, cellRect.origin.y - 10);
    [_gridView scrollPoint:pointToScrollTo];
    [_gridView deselectAll:self];
    [_gridView selectCellAtIndex:index];
}

-(OPGridViewCell*)cellForItem:(id<XPItem>)item gridView:(OEGridView*)gridView index:(NSUInteger)index
{
    OPGridViewCell *cell = (OPGridViewCell *)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
    if (!cell)
    {
        cell = (OPGridViewCell *)[gridView dequeueReusableCell];
    }
    if (![item respondsToSelector:@selector(collection)])
    {
        cell = [[OPGridViewCell alloc] init];
    }
    else
    {
        cell = [[OPPhotoGridViewCell alloc] init];
    }

    return cell;
}

-(OPGridViewCell *)gridView:(OEGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    id<XPItem> item = _items[index];
    
    OPGridViewCell *cell = [self cellForItem:item gridView:gridView index:index];
    
    cell.representedObject = item;
    
    OPGridViewCell * __weak weakCell = cell;
    id<XPItem> __weak weakItem = item;
    
    id<XPPhoto> photo;
    
    if (![item respondsToSelector:@selector(collection)])
    {
        id<XPPhotoCollection> collection = (id<XPPhotoCollection>)item;
        photo = [collection coverPhoto];
    }
    else
    {
        photo = (id<XPPhoto>)item;
    }
    
    cell.title = [item title];
    cell.image = [[OPImagePreviewService defaultService] previewImageWithPhoto:photo loaded:^(NSImage *image)
                  {
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
        for (id<XPPhotoCollectionProvider> provider in [XPExposureService photoCollectionProviders])
        {
            if ([provider respondsToSelector:@selector(badgeLayerForPhoto:)] && [item respondsToSelector:@selector(collection)])
            {
                cell.badgeLayer = [provider badgeLayerForPhoto:(id<XPPhoto>)item];
                if (cell.badgeLayer)
                {
                    break;
                }
            }
            else if ([provider respondsToSelector:@selector(badgeLayerForCollection:)] && ![item respondsToSelector:@selector(collection)])
            {
                cell.badgeLayer = [provider badgeLayerForCollection:(id<XPPhotoCollection>)item];
                if (cell.badgeLayer)
                {
                    break;
                }
            }
        }
    }
    
    return cell;
}

-(NSUInteger)numberOfItemsInGridView:(OEGridView *)gridView
{
    return _items.count;
}

-(void)popoverWillShow:(NSNotification *)notification
{
    CGFloat itemHeight = _gridView.rowSpacing + _gridView.itemSize.height;
    CGFloat estimatedHeight = itemHeight * _items.count;
    NSRect windowFrame = [[NSApp mainWindow] frame];

    CGFloat popoverHeight = windowFrame.size.height / 1.1;
    
    if (estimatedHeight < popoverHeight)
    {
        popoverHeight = estimatedHeight;
    }
    else
    {
        CGFloat visibleItems = floorf(popoverHeight / itemHeight);
        popoverHeight = visibleItems * itemHeight;
    }
    
    NSRect frame = NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, popoverHeight);
    
    [self.view setFrame:frame];
    [_popover setContentSize:self.view.frame.size];
}

-(void)popoverDidShow:(NSNotification *)notification
{
    NSUInteger index = NSNotFound;
    
    OPNavigationViewController *viewController = _navigationController.peekAtPreviousViewController;
    if (viewController && [viewController conformsToProtocol:@protocol(XPPhotoCollectionViewController)])
    {
        id<XPPhotoCollectionViewController> photoCollectionViewController = (id<XPPhotoCollectionViewController>)viewController;
        
        id<XPPhotoController> photoController = (id<XPPhotoController>)_navigationController.visibleViewController;
        
        index = [[[photoCollectionViewController visibleCollection] allPhotos] indexOfObject:[photoController visiblePhoto]];
    }
    else if (viewController && [viewController conformsToProtocol:@protocol(XPCollectionViewController)])
    {
        id<XPCollectionViewController> collectionViewController = (id<XPCollectionViewController>)viewController;
        
        id<XPPhotoCollectionViewController> photoCollectionViewController = (id<XPPhotoCollectionViewController>)_navigationController.visibleViewController;
        
        index = [[collectionViewController collections] indexOfObject:[photoCollectionViewController visibleCollection]];
    }
    
    if (index != NSNotFound)
    {
        NSRect cellRect = [_gridView rectForCellAtIndex:index];
        
        NSPoint pointToScrollTo = NSMakePoint(cellRect.origin.x, cellRect.origin.y - 10);
        [_gridView scrollPoint:pointToScrollTo];
        [_gridView deselectAll:self];
        [_gridView selectCellAtIndex:index];
    }
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    if (_items.count > 0)
    {
        id<XPItem> item = [_items firstObject];
        if ([item respondsToSelector:@selector(collection)])
        {
            _gridView = _photoGridView;
        }
        else
        {
            _gridView = _collectionGridView;
        }
        
        [_gridView.enclosingScrollView setHidden:NO];
    }
    else
    {
        [_photoGridView.enclosingScrollView setHidden:YES];
        [_collectionGridView.enclosingScrollView setHidden:YES];
    }
}

@end
