//
//  OPLocalPlugin.m
//  Optique
//
//  Created by James Dumay on 17/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPLocalPlugin.h"
#import "OPLocalCollection.h"
#import "OPLocalItem.h"
#import "NSURL+Renamer.h"

@implementation OPLocalPlugin

-(void)pluginDidLoad:(NSDictionary *)userInfo
{
    _collections = [NSMutableSet set];
}

-(void)pluginWillUnload:(NSDictionary *)userInfo
{
    [_collections removeAllObjects];
}

-(void)collectionManagerWasCreated:(XPCollectionManager *)collectionManager
{
    if (_watcher)
    {
        [_watcher stopWatching];
    }
    
    _collectionManager = collectionManager;
    _watcher = [[OPCollectionWatcher alloc] initWithCollectionManager:_collectionManager plugin:self];
    [_watcher startWatching];
    [_watcher scanForNewCollections];
}

-(id<XPItemCollection>)collectionWithTitle:(NSString *)title path:(NSURL *)path
{
    return [[OPLocalCollection alloc] initWithTitle:title path:path collectionManager:_collectionManager];
}

-(id<XPItem>)itemForURL:(NSURL *)url collection:(id<XPItemCollection>)collection
{
    NSURL *destURL = [[[collection path] URLByAppendingPathComponent:[url lastPathComponent]] URLWithUniqueNameIfExistsAtParent];
    [[NSFileManager defaultManager] copyItemAtURL:url toURL:destURL error:nil];
    
    XPItemType type = XPItemTypeForPath(destURL);
    if (type != XPItemTypeUnknown)
    {
        return [[OPLocalItem alloc] initWithTitle:[url lastPathComponent] path:destURL album:collection type:type];
    }
    return nil;
}

-(void)didAddCollections:(NSArray *)albums
{
    NSMutableSet *albumsToRemove = [NSMutableSet setWithSet:self.collections];
    [albumsToRemove minusSet:[NSMutableSet setWithArray:albums]];
    
    for (id<XPItemCollection> collection in albumsToRemove)
    {
        [self didRemoveCollection:collection];
    }
    
    for (id<XPItemCollection> collection in albums)
    {
        [self didAddCollection:collection];
    }
}

-(void)didAddCollection:(id<XPItemCollection>)collection
{
    [_collections addObject:collection];
    [_delegate didAddItemCollection:collection];
}

-(void)didRemoveCollection:(id<XPItemCollection>)collection
{
    [_collections removeObject:collection];
    [_delegate didRemoveItemCollection:collection];
}

-(id<XPItemCollection>)collectionForURL:(NSURL *)url
{
    for (id<XPItemCollection> collection in _collections)
    {
        if ([collection.path isEqualTo:url])
        {
            return collection;
        }
    }
    return nil;
}

-(NSArray *)debugMenuItems
{
    XPMenuItem *clearCacheItem = [[XPMenuItem alloc] initWithTitle:@"Rescan" keyEquivalent:@"" block:^(NSMenuItem *sender) {
        [_watcher scanForNewCollections];
    }];
    return @[clearCacheItem];
}

@end
