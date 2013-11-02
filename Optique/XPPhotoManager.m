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
#import "NSLock+WithBlock.h"

NSString *const XPPhotoManagerDidAddCollection = @"XPPhotoManagerDidAddAlbum";
NSString *const XPPhotoManagerDidUpdateCollection = @"XPPhotoManagerDidUpdateAlbum";
NSString *const XPPhotoManagerDidDeleteCollection = @"XPPhotoManagerDidDeleteAlbum";

@implementation XPPhotoManager {
    NSMutableOrderedSet *_collectionSet;
    NSLock *_collectionLock;
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
        
        _collectionLock = [[NSLock alloc] init];
    }
    return self;
}

-(NSArray *)allCollections
{
    return [_collectionLock withBlock:^id{
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

-(id<XPPhotoCollection>)newAlbumWithName:(NSString *)albumName error:(NSError *__autoreleasing *)error
{
    return [_collectionLock withBlock:^id{
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
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Could not create album %@.", albumName],
                                           NSLocalizedRecoverySuggestionErrorKey: @"There was a problem creating the album."};
                *error = [[NSError alloc] initWithDomain:@"com.whimsy.optique" code:2 userInfo:userInfo];
            }
        }
        else
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Album with the name %@ already exists.", albumName], NSLocalizedRecoverySuggestionErrorKey: @"Try choosing a different name that isn't the name of an existing album."};
            
            *error = [[NSError alloc] initWithDomain:@"com.whimsy.optique" code:1 userInfo:userInfo];
        }
        return nil;
    }];
}

-(void)deleteAlbum:(id<XPPhotoCollection>)collection error:(NSError *__autoreleasing *)error
{
    [_collectionLock withBlock:^id{
        id album = collection;
        [self sendAlbumDeletedNotification:collection];
        
        if ([album respondsToSelector:@selector(path)])
        {
            [[NSFileManager defaultManager] removeItemAtURL:(NSURL*)[album path] error:error];
            [self removeAlbum:collection];
        }
        return nil;
    }];
}

-(void)renameAlbum:(id<XPPhotoCollection>)collection to:(NSString *)name error:(NSError *__autoreleasing *)error
{
    [_collectionLock withBlock:^id{
        id album = collection;
        BOOL srcIsDir;
        if ([album respondsToSelector:@selector(path)] && [[NSFileManager defaultManager] fileExistsAtPath:[collection.path path] isDirectory:&srcIsDir])
        {
            NSURL *destURL = [[collection.path URLByDeletingLastPathComponent] URLByAppendingPathComponent:name];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:destURL.path])
            {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Album with the name %@ already exists.", name], NSLocalizedRecoverySuggestionErrorKey: @"Try choosing a different name that isn't the name of an existing album."};
                
                *error = [[NSError alloc] initWithDomain:@"com.whimsy.optique" code:1 userInfo:userInfo];
            }
            else
            {
                [[NSFileManager defaultManager] moveItemAtURL:collection.path toURL:destURL error:error];
            }
        }
        return nil;
    }];
}

-(id<XPPhotoCollection>)createLocalPhotoCollectionWithPrototype:(id<XPPhotoCollection>)prototype identifier:(NSString *)exposureId error:(NSError *__autoreleasing *)error
{
    return [_collectionLock withBlock:^id{
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
    }];
}

-(void)collectionUpdated:(id<XPPhotoCollection>)collection reload:(BOOL)shouldReload
{
    if (shouldReload)
    {
        [collection reload];
    }
    [self sendNotificationWithName:XPPhotoManagerDidUpdateCollection forPhotoCollection:collection];
}

-(id<XPPhotoCollection>)addAlbum:(id<XPPhotoCollection>)album
{
    return [_collectionLock withBlock:^id{
        if (![_collectionSet containsObject:album])
        {
            [_collectionSet addObject:album];
            return album;
        }
        return nil;
    }];
}

-(void)removeAlbum:(id<XPPhotoCollection>)album
{
    [_collectionLock withBlock:^id{
        [_collectionSet removeObject:album];
        return nil;
    }];
}

-(void)didAddPhotoCollection:(id<XPPhotoCollection>)photoCollection
{
    __block id<XPPhotoCollection> collection;
    __block bool isUpdate = NO;
    [_collectionLock withBlock:^id{
        NSUInteger index = [_collectionSet indexOfObject:photoCollection];
        if (index != NSNotFound)
        {
            collection = [_collectionSet objectAtIndex:index];
        }
        else
        {
            [_collectionSet addObject:photoCollection];
            collection = photoCollection;
        }
        return nil;
    }];
    
    if (isUpdate)
    {
        [collection reload];
        [self sendNotificationWithName:XPPhotoManagerDidUpdateCollection forPhotoCollection:collection];
    }
    else
    {
        [self sendNotificationWithName:XPPhotoManagerDidAddCollection forPhotoCollection:photoCollection];
    }
}

-(void)didRemovePhotoCollection:(id<XPPhotoCollection>)photoCollection
{
    [_collectionLock withBlock:^id{
        [_collectionSet removeObject:photoCollection];
        return nil;
    }];
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
