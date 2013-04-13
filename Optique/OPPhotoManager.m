//
//  OPPhotoManager.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoManager.h"
#import "OPPhotoAlbum.h"
#import "OPAlbumScanner.h"
#import "CHReadWriteLock.h"
#import <BlocksKit/NSMutableOrderedSet+BlocksKit.h>
#import <BlocksKit/NSArray+BlocksKit.h>

NSString *const OPPhotoManagerDidAddAlbum = @"OPPhotoManagerDidAddAlbum";
NSString *const OPPhotoManagerDidUpdateAlbum = @"OPPhotoManagerDidUpdateAlbum";
NSString *const OPPhotoManagerDidDeleteAlbum = @"OPPhotoManagerDidDeleteAlbum";

@implementation OPPhotoManager {
    NSMutableOrderedSet *_albumSet;
    CHReadWriteLock *_lock;
}

-(id)initWithPath:(NSURL *)path
{
    self = [super init];
    if (self)
    {
        _path = path;
        _albumSet = [[NSMutableOrderedSet alloc] init];
        _lock = [[CHReadWriteLock alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foundAlbums:) name:OPAlbumScannerDidFindAlbumsNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPAlbumScannerDidFindAlbumsNotification object:nil];
}

-(NSArray *)allAlbums
{
    [_lock lock];
    @try
    {
        return [[_albumSet array] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    }
    @finally
    {
        [_lock unlock];
    }
}

-(OPPhotoAlbum *)newAlbumWithName:(NSString *)albumName error:(NSError **)error
{
    NSURL *albumPath = [self.path URLByAppendingPathComponent:albumName isDirectory:YES];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[albumPath path]])
    {
        NSError *directoryCreationError;
        
        [[NSFileManager defaultManager] createDirectoryAtURL:albumPath withIntermediateDirectories:YES attributes:nil error:&directoryCreationError];
        
        if (!error)
        {
            OPPhotoAlbum *album = [[OPPhotoAlbum alloc] initWithTitle:albumName path:albumPath];
            [self addAlbum:album];
            [self sendNotificationWithName:OPPhotoManagerDidAddAlbum forAlbum:album];
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
    [self sendAlbumDeletedNotification:photoAlbum];
    
    [[NSFileManager defaultManager] removeItemAtURL:photoAlbum.path error:nil];
    
    [self removeAlbum:photoAlbum];
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
    
    [_lock lockForWriting];
    @try
    {
        NSMutableOrderedSet *oldAlbums = [NSMutableOrderedSet orderedSetWithOrderedSet:_albumSet];
        _albumSet = [NSMutableOrderedSet orderedSetWithArray:albums];
        
        [albums each:^(id sender)
        {
            if ([oldAlbums containsObject:sender])
            {
                [self sendNotificationWithName:OPPhotoManagerDidUpdateAlbum forAlbum:sender];
            }
        }];
        
        NSMutableOrderedSet *newItems = [NSMutableOrderedSet orderedSetWithArray:albums];
        [newItems minusOrderedSet:oldAlbums];
        [[newItems array] each:^(id sender) {
            [self sendNotificationWithName:OPPhotoManagerDidAddAlbum forAlbum:sender];
        }];
        
        NSMutableOrderedSet *removedItems = [NSMutableOrderedSet orderedSetWithOrderedSet:oldAlbums];
        [removedItems minusOrderedSet:[NSMutableOrderedSet orderedSetWithArray:albums]];
        
        [[removedItems array] each:^(id sender) {
            [self sendAlbumDeletedNotification:sender];
        }];
    }
    @finally
    {
        [_lock unlock];
    }
}

-(OPPhotoAlbum*)addAlbum:(OPPhotoAlbum*)album
{
    [_lock lockForWriting];
    @try
    {
        if (![_albumSet containsObject:album])
        {
            [_albumSet addObject:album];
            return album;
        }
        return nil;
    }
    @finally
    {
        [_lock unlock];
    }
}

-(void)removeAlbum:(OPPhotoAlbum*)album
{
    [_lock lockForWriting];
    @try
    {
        [_albumSet removeObject:album];
    }
    @finally
    {
        [_lock unlock];
    }
}

-(void)sendNotificationWithName:(NSString*)notificationName forAlbum:(OPPhotoAlbum*)album
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"album": album, @"photoManager": self}];
}

-(void)sendAlbumDeletedNotification:(OPPhotoAlbum*)photoAlbum
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OPPhotoManagerDidDeleteAlbum object:nil userInfo:@{@"title": photoAlbum.title, @"photoManager": self}];
}

@end
