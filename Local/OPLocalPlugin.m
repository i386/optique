//
//  OPLocalPlugin.m
//  Optique
//
//  Created by James Dumay on 17/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPLocalPlugin.h"
#import "OPPhotoAlbum.h"

@implementation OPLocalPlugin

-(void)photoManagerWasCreated:(XPPhotoManager *)photoManager
{
    if (_albumScanner)
    {
        [_albumScanner stopScan];
    }
    
    _photomanager = photoManager;
    _albumScanner = [[OPAlbumScanner alloc] initWithPhotoManager:_photomanager plugin:self];
    [_albumScanner startScan];
}

-(id<XPPhotoCollection>)createCollectionWithTitle:(NSString *)title path:(NSURL *)path
{
    return [[OPPhotoAlbum alloc] initWithTitle:title path:path photoManager:_photomanager];
}

-(void)didAddAlbum:(OPPhotoAlbum *)album
{
    [_photoCollections addObject:album];
    [_delegate didAddPhotoCollection:album];
}

-(void)didRemoveAlbum:(OPPhotoAlbum *)album
{
    [_photoCollections removeObject:album];
    [_delegate didRemovePhotoCollection:album];
}

-(NSArray *)debugMenuItems
{
    XPMenuItem *clearCacheItem = [[XPMenuItem alloc] initWithTitle:@"Rescan" keyEquivalent:@"" block:^(NSMenuItem *sender) {
        [_albumScanner startScan];
    }];
    return @[clearCacheItem];
}

@end
