//
//  XPPhotoManager.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAlbumScanner.h"
#import <BlocksKit/NSMutableOrderedSet+BlocksKit.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import <Exposure/Exposure.h>

NSString *const XPPhotoManagerDidAddCollection = @"XPPhotoManagerDidAddAlbum";
NSString *const XPPhotoManagerDidUpdateCollection = @"XPPhotoManagerDidUpdateAlbum";
NSString *const XPPhotoManagerDidDeleteCollection = @"XPPhotoManagerDidDeleteAlbum";

@implementation XPPhotoManager {
    NSMutableOrderedSet *_collectionSet;
}

-(id)initWithPath:(NSURL *)path
{
    self = [super init];
    if (self)
    {
        _path = path;
        _collectionSet = [[NSMutableOrderedSet alloc] init];
        
        //Register all photocollection providers
        [[XPExposureService photoCollectionProviders] each:^(id<XPPhotoCollectionProvider> sender) {
            sender.delegate = self;
        }];
    }
    return self;
}

-(NSArray *)allCollections
{
    return [[_collectionSet array] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]]];
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

-(id<XPPhotoCollection>)newAlbumWithName:(NSString *)albumName error:(NSError *__autoreleasing *)error
{
    NSURL *albumPath = [self.path URLByAppendingPathComponent:albumName isDirectory:YES];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[albumPath path]])
    {
        NSError *directoryCreationError;
        
        [[NSFileManager defaultManager] createDirectoryAtURL:albumPath withIntermediateDirectories:YES attributes:nil error:&directoryCreationError];
        
        if (!directoryCreationError)
        {
            id<XPPhotoCollection> album = [XPExposureService createCollectionWithTitle:albumName path:albumPath];
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
                
                XPBundleMetadata *metadata = [XPBundleMetadata createMetadataForPath:albumPath bundleId:exposureId];
                [metadata.bundleData addEntriesFromDictionary:collectionMetadata];
                [metadata write];
                
                return prototype;
            }
            else
            {
                id<XPPhotoCollection> album = [XPExposureService createCollectionWithTitle:prototype.title path:albumPath];
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
    id album = collection;
    [self sendAlbumDeletedNotification:collection];
    [[NSFileManager defaultManager] removeItemAtURL:[album path] error:nil];
    [self removeAlbum:collection];
}

-(void)collectionUpdated:(id<XPPhotoCollection>)collection
{
    [collection reload];
    [self sendNotificationWithName:XPPhotoManagerDidUpdateCollection forPhotoCollection:collection];
}

-(id<XPPhotoCollection>)addAlbum:(id<XPPhotoCollection>)album
{
    if (![_collectionSet containsObject:album])
    {
        [_collectionSet addObject:album];
        return album;
    }
    return nil;
}

-(void)removeAlbum:(id<XPPhotoCollection>)album
{
    [_collectionSet removeObject:album];
}

-(void)didAddPhotoCollection:(id<XPPhotoCollection>)photoCollection
{
    [_collectionSet addObject:photoCollection];
    [self sendNotificationWithName:XPPhotoManagerDidAddCollection forPhotoCollection:photoCollection];
}

-(void)didRemovePhotoCollection:(id<XPPhotoCollection>)photoCollection
{
    [_collectionSet removeObject:photoCollection];
    [self sendNotificationWithName:XPPhotoManagerDidDeleteCollection forPhotoCollection:photoCollection];
}

-(void)sendNotificationWithName:(NSString*)notificationName forPhotoCollection:(id<XPPhotoCollection>)photoCollection
{
    [[NSNotificationCenter defaultCenter] postAsyncNotificationName:notificationName object:nil userInfo:@{@"collection": photoCollection, @"photoManager": self}];
}

-(void)sendAlbumDeletedNotification:(id<XPPhotoCollection>)photoAlbum
{
    [[NSNotificationCenter defaultCenter] postAsyncNotificationName:XPPhotoManagerDidDeleteCollection object:nil userInfo:@{@"title": photoAlbum.title, @"photoManager": self}];
}

@end
