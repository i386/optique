//
//  OPHistoryPeekViewController.m
//  Optique
//
//  Created by James Dumay on 4/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPHistoryPeekViewController.h"
#import "OPItemPreviewManager.h"
#import "OPPItemViewController.h"
#import "OPItemCollectionViewController.h"
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
    return ![NSWindow isFullScreen] && _items.count > 1;
}

-(void)gridView:(OEGridView *)gridView clickedCellForItemAtIndex:(NSUInteger)index
{
    id<XPItem> item = _items[index];
    
    NSViewController *controller;
    if (![item respondsToSelector:@selector(collection)])
    {
        id<XPItemCollection> collection = (id<XPItemCollection>)item;
        controller = [[OPItemCollectionViewController alloc] initWithIemCollection:collection collectionManager:[collection collectionManager]];
    }
    else
    {
        controller = [[OPPItemViewController alloc] initWithItem:_items[index]];
    }
    
    [_navigationController popToPreviousViewController];
    [_navigationController pushViewController:controller];
    
    NSRect cellRect = [_gridView rectForCellAtIndex:index];
    
    NSPoint pointToScrollTo = NSMakePoint(cellRect.origin.x, cellRect.origin.y - 10);
    [_gridView scrollPoint:pointToScrollTo];
    [_gridView deselectAll:self];
    [_gridView selectCellAtIndex:index];
}

-(OPGridViewCell*)cellForObject:(id)obj gridView:(OEGridView*)gridView index:(NSUInteger)index
{
    OPGridViewCell *cell = (OPGridViewCell *)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
    if (!cell)
    {
        cell = (OPGridViewCell *)[gridView dequeueReusableCell];
    }
    
    if (![obj conformsToProtocol:@protocol(XPItem)])
    {
        cell = [[OPGridViewCell alloc] init];
    }
    else
    {
        cell = [[OPItemGridViewCell alloc] init];
    }

    return cell;
}

-(OPGridViewCell *)gridView:(OEGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    id obj = _items[index];
    
    OPGridViewCell *cell = [self cellForObject:obj gridView:gridView index:index];
    
    cell.representedObject = obj;
    
    OPGridViewCell * __weak weakCell = cell;
    id<XPItem> __weak item;
    
    if ([obj conformsToProtocol:@protocol(XPItemCollection)])
    {
        id<XPItemCollection> collection = (id<XPItemCollection>)obj;
        item = [collection coverItem];
    }
    else
    {
        item = (id<XPItem>)obj;
    }
    
    cell.representedObject = item;
    cell.title = [obj title];
    
    [[OPItemPreviewManager defaultManager] previewItem:item size:_gridView.itemSize loaded:^(NSImage *image) {
        [self performBlockOnMainThread:^
        {
            if (item == weakCell.representedObject)
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
            if ([provider respondsToSelector:@selector(badgeLayerForItem:)] && [item respondsToSelector:@selector(collection)])
            {
                cell.badgeLayer = [provider badgeLayerForItem:(id<XPItem>)item];
                if (cell.badgeLayer)
                {
                    break;
                }
            }
            else if ([provider respondsToSelector:@selector(badgeLayerForCollection:)] && ![item respondsToSelector:@selector(collection)])
            {
                cell.badgeLayer = [provider badgeLayerForCollection:(id<XPItemCollection>)item];
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
    CGFloat estimatedPopoverHeight = itemHeight * _items.count;
    NSRect windowFrame = [[NSApp mainWindow] frame];
    CGFloat popoverHeight = windowFrame.size.height;
    
    if (estimatedPopoverHeight < popoverHeight)
    {
        popoverHeight = estimatedPopoverHeight;
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
    
    NSViewController *viewController = _navigationController.peekAtPreviousViewController;
    if (viewController && [viewController conformsToProtocol:@protocol(XPItemCollectionViewController)])
    {
        id<XPItemCollectionViewController> itemCollectionViewController = (id<XPItemCollectionViewController>)viewController;
        
        id<XPItemController> itemController = (id<XPItemController>)_navigationController.visibleViewController;
        
        index = [[[itemCollectionViewController visibleCollection] allItems] indexOfObject:[itemController item]];
    }
    else if (viewController && [viewController conformsToProtocol:@protocol(XPCollectionViewController)])
    {
        id<XPCollectionViewController> collectionViewController = (id<XPCollectionViewController>)viewController;
        
        id<XPItemCollectionViewController> itemCollectionViewController = (id<XPItemCollectionViewController>)_navigationController.visibleViewController;
        
        index = [[collectionViewController collections] indexOfObject:[itemCollectionViewController visibleCollection]];
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
    
    _collectionGridView.ignoreSizePreference = YES;
    _itemGridView.ignoreSizePreference = YES;
    
    if (_items.count > 0)
    {
        id<XPItem> item = [_items firstObject];
        if ([item respondsToSelector:@selector(collection)])
        {
            _gridView = _itemGridView;
        }
        else
        {
            _gridView = _collectionGridView;
        }
        
        [_gridView.enclosingScrollView setHidden:NO];
    }
    else
    {
        [_itemGridView.enclosingScrollView setHidden:YES];
        [_collectionGridView.enclosingScrollView setHidden:YES];
    }
}

@end
