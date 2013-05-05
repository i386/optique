//
//  OPPhotoManager.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoManager.h"
#import "OPCameraService.h"
#import "OPPhotoAlbum.h"
#import "OPCamera.h"
#import "OPAlbumScanner.h"
#import <BlocksKit/NSMutableOrderedSet+BlocksKit.h>
#import <BlocksKit/NSArray+BlocksKit.h>

NSString *const OPPhotoManagerDidAddCollection = @"OPPhotoManagerDidAddAlbum";
NSString *const OPPhotoManagerDidUpdateCollection = @"OPPhotoManagerDidUpdateAlbum";
NSString *const OPPhotoManagerDidDeleteCollection = @"OPPhotoManagerDidDeleteAlbum";

@implementation OPPhotoManager {
    NSMutableOrderedSet *_collectionSet;
    NSLock *_lock;
}

-(id)initWithPath:(NSURL *)path
{
    self = [super init];
    if (self)
    {
        _path = path;
        _collectionSet = [[NSMutableOrderedSet alloc] init];
        _lock = [[NSLock alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foundAlbums:) name:OPAlbumScannerDidFindAlbumsNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foundCamera:) name:OPCameraServiceDidAddCamera object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removedCamera:) name:OPCameraServiceDidRemoveCamera object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumScannerDidFindAlbumsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPCameraServiceDidAddCamera object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPCameraServiceDidRemoveCamera object:nil];
}

-(NSArray *)allCollections
{
    return [self withLock:^id{
        return [[_collectionSet array] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    }];
}

-(NSArray *)allCollectionsForIndexSet:(NSIndexSet *)indexSet
{
    NSMutableArray *albums = [NSMutableArray array];
    NSArray *collections = [self allCollections];
    [indexSet each:^(NSUInteger index) {
        id collection = collections[index];
        [albums addObject:collection];
    }];
    return albums;
}

-(OPPhotoAlbum *)newAlbumWithName:(NSString *)albumName error:(NSError **)error
{
    NSURL *albumPath = [self.path URLByAppendingPathComponent:albumName isDirectory:YES];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[albumPath path]])
    {
        NSError *directoryCreationError;
        
        [[NSFileManager defaultManager] createDirectoryAtURL:albumPath withIntermediateDirectories:YES attributes:nil error:&directoryCreationError];
        
        if (!directoryCreationError)
        {
            OPPhotoAlbum *album = [[OPPhotoAlbum alloc] initWithTitle:albumName path:albumPath photoManager:self];
            [self addAlbum:album];
            [self sendNotificationWithName:OPPhotoManagerDidAddCollection forPhotoCollection:album];
            return album;
        }
        else
        {
            *error = [[NSError alloc] initWithDomain:@"OPPhotoManager" code:2 userInfo:@{@"message": [NSString stringWithFormat:@"Could not create album %@.", albumName], @"longmessage": @"There was a problem creating the album."}];
        }
    }
    else
    {
        *error = [[NSError alloc] initWithDomain:@"OPPhotoManager" code:1 userInfo:@{@"message": [NSString stringWithFormat:@"Album with the name %@ already exists.", albumName], @"longmessage": @"Try choosing a different name that isn't the name of an existing album."}];
    }
    return nil;
}

-(void)deleteAlbum:(OPPhotoAlbum *)photoAlbum
{    
    [self withLock:^id{
        [self sendAlbumDeletedNotification:photoAlbum];
        
        [[NSFileManager defaultManager] removeItemAtURL:photoAlbum.path error:nil];
        
        [self removeAlbum:photoAlbum];
        
        return nil;
    }];
}

-(void)collectionUpdated:(id<OPPhotoCollection>)collection
{
    [collection reload];
    [self sendNotificationWithName:OPPhotoManagerDidUpdateCollection forPhotoCollection:collection];
}

-(void)foundAlbums:(NSNotification*)event
{
    NSDictionary *userInfo = event.userInfo;
    NSArray *albums = userInfo[@"albums"];
    OPPhotoManager *photoManager = userInfo[@"photoManager"];
    
    if ([photoManager isNotEqualTo:self])
    {
        return;
    }
    
    [self withLock:^id{
        NSMutableOrderedSet *oldAlbums = [NSMutableOrderedSet orderedSetWithOrderedSet:_collectionSet];
        _collectionSet = [NSMutableOrderedSet orderedSetWithArray:albums];
        
        [albums each:^(id sender)
         {
             if ([oldAlbums containsObject:sender])
             {
                 [self sendNotificationWithName:OPPhotoManagerDidUpdateCollection forPhotoCollection:sender];
             }
         }];
        
        NSMutableOrderedSet *newItems = [NSMutableOrderedSet orderedSetWithArray:albums];
        [newItems minusOrderedSet:oldAlbums];
        [[newItems array] each:^(id sender) {
            [self performBlockInBackground:^{
                [self sendNotificationWithName:OPPhotoManagerDidAddCollection forPhotoCollection:sender];
            }];
        }];
        
        NSMutableOrderedSet *removedItems = [NSMutableOrderedSet orderedSetWithOrderedSet:oldAlbums];
        [removedItems minusOrderedSet:[NSMutableOrderedSet orderedSetWithArray:albums]];
        
        
        
        [[removedItems array] each:^(id sender) {
            [self sendAlbumDeletedNotification:sender];
        }];
        
        return nil;
    }];
}

-(OPPhotoAlbum*)addAlbum:(OPPhotoAlbum*)album
{
    return [self withLock:^id{
        if (![_collectionSet containsObject:album])
        {
            [_collectionSet addObject:album];
            return album;
        }
        return nil;
    }];
}

-(void)removeAlbum:(OPPhotoAlbum*)album
{
    [self withLock:^id{
        [_collectionSet removeObject:album];
        return nil;
    }];
}

-(void)foundCamera:(NSNotification*)notification
{
    OPCamera *camera = notification.userInfo[@"camera"];
    if (camera)
    {
        [self withLock:^id{
            [_collectionSet addObject:camera];
            [self sendNotificationWithName:OPPhotoManagerDidUpdateCollection forPhotoCollection:camera];
            return nil;
        }];
    }
}

-(void)removedCamera:(NSNotification*)notification
{
    OPCamera *camera = notification.userInfo[@"camera"];
    if (camera)
    {
        [self withLock:^id{
            [_collectionSet removeObject:camera];
            [self sendNotificationWithName:OPPhotoManagerDidDeleteCollection forPhotoCollection:camera];
            return nil;
        }];
    }
}

-(id)withLock:(id (^)(void))block
{
    [_lock lock];
    @try
    {
        return block();
    }
    @finally
    {
        [_lock unlock];
    }
}

-(void)sendNotificationWithName:(NSString*)notificationName forPhotoCollection:(id<OPPhotoCollection>)photoCollection
{
    [[NSNotificationCenter defaultCenter] postAsyncNotificationName:notificationName object:nil userInfo:@{@"collection": photoCollection, @"photoManager": self}];
}

-(void)sendAlbumDeletedNotification:(OPPhotoAlbum*)photoAlbum
{
    [[NSNotificationCenter defaultCenter] postAsyncNotificationName:OPPhotoManagerDidDeleteCollection object:nil userInfo:@{@"title": photoAlbum.title, @"photoManager": self}];
}

@end
