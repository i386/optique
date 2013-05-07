//
//  OPFinderPlugin.m
//  Optique
//
//  Created by James Dumay on 6/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFinderPlugin.h"

@implementation OPFinderPlugin

-(void)photoManager:(XPPhotoManager *)photoManager collectionViewController:(id<XPCollectionViewController>)controller
{
    XPPhotoManager * __weak weakPhotoManager = photoManager;
    
    XPMenuItem *item = [[XPMenuItem alloc] initWithTitle:@"Show in Finder" keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        NSIndexSet *indexes = (NSIndexSet*)sender.representedObject;
        NSMutableArray *urls = [NSMutableArray array];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop)
         {
             id collection = weakPhotoManager.allCollections[index];
             if ([collection isStoredOnFileSystem] && [collection respondsToSelector:@selector(path)])
             {
                 [urls addObject:[collection path]];
             }
         }];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:urls];
    }];
    
    item.visibilityPredicate = [NSPredicate predicateWithBlock:^BOOL(NSArray *selectedItems, NSDictionary *bindings) {
        
        BOOL visible = YES;
        
        for (id<XPPhotoCollection> collection in selectedItems)
        {
            if (![collection isStoredOnFileSystem])
            {
                visible = NO;
                break;
            }
        }
        
        return visible;
    }];
    
    [[controller contextMenu] addItem:item];
}

-(void)photoManager:(XPPhotoManager *)photoManager photoCollectionViewController:(id<XPPhotoCollectionViewController>)controller
{
    XPMenuItem *item = [[XPMenuItem alloc] initWithTitle:@"Show in Finder" keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        NSIndexSet *indexes = (NSIndexSet*)sender.representedObject;
        NSMutableArray *urls = [NSMutableArray array];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop)
         {
             id photo = controller.visibleCollection.allPhotos[index];
             if ([photo respondsToSelector:@selector(path)])
             {
                 [urls addObject:[photo path]];
             }
         }];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:urls];
    }];
    
    item.visibilityPredicate = [NSPredicate predicateWithBlock:^BOOL(NSArray *selectedItems, NSDictionary *bindings) {
        
        BOOL visible = YES;
        
        for (id<XPPhotoCollection> collection in selectedItems)
        {
            if (![collection isStoredOnFileSystem])
            {
                visible = NO;
                break;
            }
        }
        
        return visible;
    }];
    
    [[controller contextMenu] addItem:item];
}

-(void)photoManager:(XPPhotoManager *)photoManager photoController:(id<XPPhotoController>)controller
{
    XPMenuItem *item = [[XPMenuItem alloc] initWithTitle:@"Show in Finder" keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        id photo = controller.visiblePhoto;
        if ([photo respondsToSelector:@selector(path)])
        {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[photo path]]];
        }
    }];
    
    item.visibilityPredicate = [NSPredicate predicateWithBlock:^BOOL(id<XPPhoto> photo, NSDictionary *bindings) {
        return [[photo collection] isStoredOnFileSystem];
    }];
    
    [[controller contextMenu] addItem:item];
}


@end