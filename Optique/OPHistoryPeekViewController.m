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
    
    [_navigationController popToRootViewControllerWithNoAnimation];
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
