//
//  OPLocalPlugin.m
//  Optique
//
//  Created by James Dumay on 17/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPLocalPlugin.h"
#import "OPLocalCollection.h"

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
    if (_scanner)
    {
        [_scanner stopScan];
    }
    
    _collectionManager = collectionManager;
    _scanner = [[OPCollectionScanner alloc] initWithCollectionManager:_collectionManager plugin:self];
    [_scanner startScan];
}

-(id<XPItemCollection>)createCollectionWithTitle:(NSString *)title path:(NSURL *)path
{
    return [[OPLocalCollection alloc] initWithTitle:title path:path collectionManager:_collectionManager];
}

-(void)didAddAlbums:(NSArray *)albums
{
    NSMutableSet *albumsToRemove = [NSMutableSet setWithSet:self.collections];
    [albumsToRemove minusSet:[NSMutableSet setWithArray:albums]];
    
    for (OPLocalCollection *album in albumsToRemove)
    {
        [self didRemoveAlbum:album];
    }
    
    for (OPLocalCollection *album in albums)
    {
        [self didAddAlbum:album];
    }
}

-(void)didAddAlbum:(OPLocalCollection *)album
{
    [_collections addObject:album];
    [_delegate didAddItemCollection:album];
}

-(void)didRemoveAlbum:(OPLocalCollection *)album
{
    [_collections removeObject:album];
    [_delegate didRemoveItemCollection:album];
}

-(NSArray *)debugMenuItems
{
    XPMenuItem *clearCacheItem = [[XPMenuItem alloc] initWithTitle:@"Rescan" keyEquivalent:@"" block:^(NSMenuItem *sender) {
        [_scanner startScan];
    }];
    return @[clearCacheItem];
}

@end
