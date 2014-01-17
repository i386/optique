//
//  OPFinderPlugin.m
//  Optique
//
//  Created by James Dumay on 6/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFinderPlugin.h"

@implementation OPFinderPlugin

-(void)collectionManager:(XPCollectionManager *)collectionManager collectionViewController:(id<XPCollectionViewController>)controller
{
    XPCollectionManager * __weak weakCollectionManager = collectionManager;
    
    XPMenuItem *item = [[XPMenuItem alloc] initWithTitle:@"Show in Finder" keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        NSIndexSet *indexes = [controller selectedItems];
        NSMutableArray *urls = [NSMutableArray array];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop)
         {
             id collection = weakCollectionManager.allCollections[index];
             if ([collection respondsToSelector:@selector(path)])
             {
                 [urls addObject:[collection path]];
             }
         }];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:urls];
    }];
    
    item.visibilityPredicate = [NSPredicate predicateWithBlock:^BOOL(NSArray *selectedItems, NSDictionary *bindings) {
        
        BOOL visible = YES;
        
        for (id<XPItemCollection> collection in selectedItems)
        {
            if ([collection collectionType] != XPItemCollectionLocal)
            {
                visible = NO;
                break;
            }
        }
        
        return visible;
    }];
    
    [[controller contextMenu] addItem:item];
}

-(void)collectionManager:(XPCollectionManager *)collectionManager itemCollectionViewController:(id<XPItemCollectionViewController>)controller
{
    XPMenuItem *item = [[XPMenuItem alloc] initWithTitle:@"Show in Finder" keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        NSIndexSet *indexes = [controller selectedItems];
        NSMutableArray *urls = [NSMutableArray array];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop)
         {
             id item = controller.visibleCollection.allItems[index];
             if ([item hasLocalCopy])
             {
                 [urls addObject:[item url]];
             }
         }];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:urls];
    }];
    
    item.visibilityPredicate = [NSPredicate predicateWithBlock:^BOOL(NSArray *selectedItems, NSDictionary *bindings) {
        
        BOOL visible = YES;
        
        for (id<XPItemCollection> collection in selectedItems)
        {
            if ([collection collectionType] != XPItemCollectionLocal)
            {
                visible = NO;
                break;
            }
        }
        
        return visible;
    }];
    
    [[controller contextMenu] addItem:item];
}

-(void)collectionManager:(XPCollectionManager *)collectionManager itemController:(id<XPItemController>)controller
{
    XPMenuItem *item = [[XPMenuItem alloc] initWithTitle:@"Show in Finder" keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        id item = controller.item;
        if ([item hasLocalCopy])
        {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[item url]]];
        }
    }];
    
    item.visibilityPredicate = [NSPredicate predicateWithBlock:^BOOL(id<XPItem> item, NSDictionary *bindings) {
        return [[item collection] collectionType] != XPItemCollectionLocal;
    }];
    
    [[controller contextMenu] addItem:item];
}


@end
