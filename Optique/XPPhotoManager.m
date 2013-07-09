//
//  XPPhotoManager.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoAlbum.h"
#import "OPAlbumScanner.h"
#import <BlocksKit/NSMutableOrderedSet+BlocksKit.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import <Exposure/Exposure.h>
#import "OPExposureService.h"

NSString *const XPPhotoManagerDidAddCollection = @"XPPhotoManagerDidAddAlbum";
NSString *const XPPhotoManagerDidUpdateCollection = @"XPPhotoManagerDidUpdateAlbum";
NSString *const XPPhotoManagerDidDeleteCollection = @"XPPhotoManagerDidDeleteAlbum";

@implementation XPPhotoManager {
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
        
        //Register all photocollection providers
        [[OPExposureService photoCollectionProviders] each:^(id<XPPhotoCollectionProvider> sender) {
            sender.delegate = self;
        }];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumScannerDidFindAlbumsNotification object:nil];
}

-(NSArray *)allCollections
{
    return [self withLock:^id{
        return [[_collectionSet array] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]]];
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

-(id<XPPhotoCollection>)newAlbumWithName:(NSString *)albumName identifier:(NSString *)exposureId error:(NSError *__autoreleasing *)error
{
    NSURL *albumPath = [self.path URLByAppendingPathComponent:albumName isDirectory:YES];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[albumPath path]])
    {
        NSError *directoryCreationError;
        
        [[NSFileManager defaultManager] createDirectoryAtURL:albumPath withIntermediateDirectories:YES attributes:nil error:&directoryCreationError];
        
        if (!directoryCreationError)
        {
            if (exposureId)
            {
                NSDictionary *metadata = @{fOptiqueBundle: exposureId};
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:metadata options:NSJSONWritingPrettyPrinted error:nil];
                NSURL *metadataURL = [albumPath URLByAppendingPathComponent:fOptiqueMetadataFileName];
                [jsonData writeToURL:metadataURL atomically:YES];
            }
            
            OPPhotoAlbum *album = [[OPPhotoAlbum alloc] initWithTitle:albumName path:albumPath photoManager:self];
            [self addAlbum:album];
            [self sendNotificationWithName:XPPhotoManagerDidAddCollection forPhotoCollection:album];
            return album;
        }
        else
        {
            *error = [[NSError alloc] initWithDomain:@"XPPhotoManager" code:2 userInfo:@{@"message": [NSString stringWithFormat:@"Could not create album %@.", albumName], @"longmessage": @"There was a problem creating the album."}];
        }
    }
    else
    {
        *error = [[NSError alloc] initWithDomain:@"XPPhotoManager" code:1 userInfo:@{@"message": [NSString stringWithFormat:@"Album with the name %@ already exists.", albumName], @"longmessage": @"Try choosing a different name that isn't the name of an existing album."}];
    }
    return nil;
}

-(id<XPPhotoCollection>)createLocalPhotoCollectionWithPrototype:(id<XPPhotoCollection>)prototype identifier:(NSString *)exposureId error:(NSError *__autoreleasing *)error
{
    NSURL *albumPath = [self.path URLByAppendingPathComponent:prototype.title isDirectory:YES];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[albumPath path]])
    {
        NSError *directoryCreationError;
        
        [[NSFileManager defaultManager] createDirectoryAtURL:albumPath withIntermediateDirectories:YES attributes:nil error:&directoryCreationError];
        
        if (!directoryCreationError)
        {
            if (exposureId)
            {
                NSMutableArray *photos = [NSMutableArray array];
                
                for (id<XPPhoto> photo in [prototype allPhotos])
                {
                    [photos addObject:photo.metadata];
                }
                
                NSMutableDictionary *collectionMetadata = [NSMutableDictionary dictionaryWithDictionary:prototype.metadata];
                [collectionMetadata setObject:photos forKey:fOptiqueBundlePhotos];
                
                NSDictionary *metadata = @{fOptiqueBundle: exposureId, fOptiqueBundleData: collectionMetadata, fOptiqueBundlePhotos: photos};
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:metadata options:NSJSONWritingPrettyPrinted error:nil];
                NSURL *metadataURL = [albumPath URLByAppendingPathComponent:fOptiqueMetadataFileName];
                [jsonData writeToURL:metadataURL atomically:YES];
                return prototype;
            }
            else
            {
                OPPhotoAlbum *album = [[OPPhotoAlbum alloc] initWithTitle:prototype.title path:albumPath photoManager:self];
                [self addAlbum:album];
                [self sendNotificationWithName:XPPhotoManagerDidAddCollection forPhotoCollection:album];
                return album;
            }
        }
        else
        {
            *error = [[NSError alloc] initWithDomain:@"XPPhotoManager" code:2 userInfo:@{@"message": [NSString stringWithFormat:@"Could not create album %@.", prototype.title], @"longmessage": @"There was a problem creating the album."}];
        }
    }
    else
    {
        *error = [[NSError alloc] initWithDomain:@"XPPhotoManager" code:1 userInfo:@{@"message": [NSString stringWithFormat:@"Album with the name %@ already exists.", prototype.title], @"longmessage": @"Try choosing a different name that isn't the name of an existing album."}];
    }
    return nil;
}

-(void)deleteAlbum:(id<XPPhotoCollection>)collection
{
    OPPhotoAlbum *album = collection;
    
    [self withLock:^id{
        [self sendAlbumDeletedNotification:album];
        
        [[NSFileManager defaultManager] removeItemAtURL:album.path error:nil];
        
        [self removeAlbum:collection];
        
        return nil;
    }];
}

-(void)collectionUpdated:(id<XPPhotoCollection>)collection
{
    [collection reload];
    [self sendNotificationWithName:XPPhotoManagerDidUpdateCollection forPhotoCollection:collection];
}

-(void)foundAlbums:(NSNotification*)event
{
    NSDictionary *userInfo = event.userInfo;
    NSArray *albums = userInfo[@"albums"];
    XPPhotoManager *photoManager = userInfo[@"photoManager"];
    
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
                 [self sendNotificationWithName:XPPhotoManagerDidUpdateCollection forPhotoCollection:sender];
             }
         }];
        
        NSMutableOrderedSet *newItems = [NSMutableOrderedSet orderedSetWithArray:albums];
        
        //Add all the collections owned by providers to the new items set so they are not removed
        [[OPExposureService photoCollectionProviders] each:^(id<XPPhotoCollectionProvider> provider) {
            [newItems addObjectsFromArray:provider.photoCollections];
        }];
        
        [newItems minusOrderedSet:oldAlbums];
        
        [[newItems array] each:^(id sender) {
            [self performBlockInBackground:^{
                [self sendNotificationWithName:XPPhotoManagerDidAddCollection forPhotoCollection:sender];
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

-(void)didAddPhotoCollection:(id<XPPhotoCollection>)photoCollection
{
    [self withLock:^id{
        [_collectionSet addObject:photoCollection];
        [self sendNotificationWithName:XPPhotoManagerDidAddCollection forPhotoCollection:photoCollection];
        return nil;
    }];
}

-(void)didRemovePhotoCollection:(id<XPPhotoCollection>)photoCollection
{
    [self withLock:^id{
        [_collectionSet removeObject:photoCollection];
        [self sendNotificationWithName:XPPhotoManagerDidDeleteCollection forPhotoCollection:photoCollection];
        return nil;
    }];
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

-(void)sendNotificationWithName:(NSString*)notificationName forPhotoCollection:(id<XPPhotoCollection>)photoCollection
{
    [[NSNotificationCenter defaultCenter] postAsyncNotificationName:notificationName object:nil userInfo:@{@"collection": photoCollection, @"photoManager": self}];
}

-(void)sendAlbumDeletedNotification:(OPPhotoAlbum*)photoAlbum
{
    [[NSNotificationCenter defaultCenter] postAsyncNotificationName:XPPhotoManagerDidDeleteCollection object:nil userInfo:@{@"title": photoAlbum.title, @"photoManager": self}];
}

@end
