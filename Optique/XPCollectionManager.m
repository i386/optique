//
//  XPCollectionManager.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <BlocksKit/NSMutableOrderedSet+BlocksKit.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import <Exposure/Exposure.h>
#import "NSLock+WithBlock.h"

NSString *const XPCollectionManagerDidAddCollection = @"XPCollectionManagerDidAddAlbum";
NSString *const XPCollectionManagerDidUpdateCollection = @"XPCollectionManagerDidUpdateAlbum";
NSString *const XPCollectionManagerDidDeleteCollection = @"XPCollectionManagerDidDeleteAlbum";

@implementation XPCollectionManager {
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
        
        //Register all collection providers
        [[XPExposureService itemCollectionProviders] bk_each:^(id<XPItemCollectionProvider> sender) {
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
    [indexSet bk_each:^(NSUInteger index) {
        id collection = collections[index];
        [albums addObject:collection];
    }];
    return albums;
}

-(id<XPItemCollection>)newAlbumWithName:(NSString *)albumName error:(NSError *__autoreleasing *)error
{
    if ([@"" isEqualToString:albumName])
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Album cannot have an empty name.", NSLocalizedRecoverySuggestionErrorKey: @"Specify a valid name before creating an album."};
        *error = [[NSError alloc] initWithDomain:@"com.whimsy.optique" code:1 userInfo:userInfo];
    }
    else
    {
    
        id<XPItemCollection> collection =  [_collectionLock withBlock:^id{
            NSURL *albumPath = [self.path URLByAppendingPathComponent:albumName isDirectory:YES];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:[albumPath path]])
            {
                NSError *directoryCreationError;
                
                [[NSFileManager defaultManager] createDirectoryAtURL:albumPath withIntermediateDirectories:YES attributes:nil error:&directoryCreationError];
                
                if (!directoryCreationError)
                {
                    id<XPItemCollection> album = [XPExposureService collectionWithTitle:albumName path:albumPath];
                    [_collectionSet addObject:album];
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
        
        if (collection)
        {
            [self sendNotificationWithName:XPCollectionManagerDidAddCollection collection:collection];
        }
        return collection;
        
    }
    return nil;
}

-(void)deleteAlbum:(id<XPItemCollection>)collection error:(NSError *__autoreleasing *)error
{
    [_collectionLock withBlock:^id{
        id album = collection;
        [self sendAlbumDeletedNotification:collection];
        
        if ([album respondsToSelector:@selector(path)])
        {
            [[NSFileManager defaultManager] removeItemAtURL:(NSURL*)[album path] error:error];
            [_collectionSet removeObject:collection];
        }
        return nil;
    }];
}

-(void)renameAlbum:(id<XPItemCollection>)collection to:(NSString *)name error:(NSError *__autoreleasing *)error
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

-(id<XPItemCollection>)createLocalPhotoCollectionWithPrototype:(id<XPItemCollection>)prototype identifier:(NSString *)exposureId error:(NSError *__autoreleasing *)error
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
                    NSMutableArray *items = [NSMutableArray array];
                    
                    for (id<XPItem> item in [prototype allItems])
                    {
                        [items addObject:item.metadata];
                    }
                    
                    NSMutableDictionary *collectionMetadata = [NSMutableDictionary dictionaryWithDictionary:prototype.metadata];
                    [collectionMetadata setObject:items forKey:XPBundleItems];
                    
                    XPBundleMetadata *metadata = [XPBundleMetadata createMetadataForPath:albumPath bundleId:exposureId];
                    [metadata.bundleData addEntriesFromDictionary:collectionMetadata];
                    [metadata write];
                    
                    return prototype;
                }
                else
                {
                    id<XPItemCollection> collection = [XPExposureService collectionWithTitle:prototype.title path:albumPath];
                    [self addAlbum:collection];
                    [self sendNotificationWithName:XPCollectionManagerDidAddCollection collection:collection];
                    return collection;
                }
            }
            else
            {
                *error = [[NSError alloc] initWithDomain:@"XPCollectionManager" code:2 userInfo:@{@"message": [NSString stringWithFormat:@"Could not create album %@.", prototype.title], @"longmessage": @"There was a problem creating the album."}];
            }
        }
        else
        {
            *error = [[NSError alloc] initWithDomain:@"XPCollectionManager" code:1 userInfo:@{@"message": [NSString stringWithFormat:@"Album with the name %@ already exists.", prototype.title], @"longmessage": @"Try choosing a different name that isn't the name of an existing album."}];
        }
        return nil;
    }];
}

-(void)collectionUpdated:(id<XPItemCollection>)collection reload:(BOOL)shouldReload
{
    if (shouldReload)
    {
        [collection reload];
    }
    [self sendNotificationWithName:XPCollectionManagerDidUpdateCollection collection:collection];
}

-(id<XPItemCollection>)addAlbum:(id<XPItemCollection>)album
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

-(void)removeAlbum:(id<XPItemCollection>)album
{
    [_collectionLock withBlock:^id{
        [_collectionSet removeObject:album];
        return nil;
    }];
}

-(void)didAddItemCollection:(id<XPItemCollection>)collection
{
    __block id<XPItemCollection> blockCollection;
    __block bool isUpdate = NO;
    [_collectionLock withBlock:^id{
        NSUInteger index = [_collectionSet indexOfObject:collection];
        if (index != NSNotFound)
        {
            blockCollection = [_collectionSet objectAtIndex:index];
        }
        else
        {
            [_collectionSet addObject:collection];
            blockCollection = collection;
        }
        return nil;
    }];
    
    if (isUpdate)
    {
        [collection reload];
        [self sendNotificationWithName:XPCollectionManagerDidUpdateCollection collection:collection];
    }
    else
    {
        [self sendNotificationWithName:XPCollectionManagerDidAddCollection collection:collection];
    }
}

-(void)didRemoveItemCollection:(id<XPItemCollection>)collection
{
    [_collectionLock withBlock:^id{
        [_collectionSet removeObject:collection];
        return nil;
    }];
    [self sendNotificationWithName:XPCollectionManagerDidDeleteCollection collection:collection];
}

-(void)sendNotificationWithName:(NSString*)notificationName collection:(id<XPItemCollection>)collection
{
    [[NSNotificationCenter defaultCenter] postAsyncNotificationName:notificationName object:nil userInfo:@{@"collection": collection, @"collectionManager": self}];
}

-(void)sendAlbumDeletedNotification:(id<XPItemCollection>)collection
{
    [[NSNotificationCenter defaultCenter] postAsyncNotificationName:XPCollectionManagerDidDeleteCollection object:nil userInfo:@{@"title": collection.title, @"collectionManager": self}];
}

@end
