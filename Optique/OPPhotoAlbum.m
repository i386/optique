//
//  OPPhotoAlbum.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoManager.h"
#import "OPPhotoAlbum.h"
#import "OPLocalPhoto.h"
#import "CHReadWriteLock.h"

@interface OPPhotoAlbum() {
    CHReadWriteLock *_arrayLock;
    volatile NSMutableOrderedSet *_allPhotos;
}

@end

@implementation OPPhotoAlbum

-(id)initWithTitle:(NSString *)title path:(NSURL *)path photoManager:(OPPhotoManager*)photoManager
{
    self = [super init];
    if (self)
    {
        _title = title;
        _path = path;
        _photoManager = photoManager;
        _arrayLock = [[CHReadWriteLock alloc] init];
    }
    return self;
}

-(NSArray *)allPhotos
{
    if (_allPhotos == nil)
    {
        [self reloadPhotos];
    }
    
    [_arrayLock lock];
    @try
    {
        return (NSArray*)_allPhotos;
    }
    @finally
    {
        [_arrayLock unlock];
    }
}

-(NSArray *)photosForIndexSet:(NSIndexSet *)indexSet
{
    NSMutableArray *albums = [NSMutableArray array];
    
    [[self allPhotos] enumerateObjectsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [albums addObject:obj];
    }];
    
    return albums;
}

-(void)reloadPhotos
{
    [_arrayLock lockForWriting];
    @try
    {
        _allPhotos = [NSMutableOrderedSet orderedSetWithArray:[self findAllPhotos]];
    }
    @finally
    {
        [_arrayLock unlock];
    }
}

-(void)deletePhoto:(id<OPPhoto>)photo error:(NSError *__autoreleasing *)error
{
//    [_arrayLock lockForWriting];
//    @try
//    {
//        //TODO check for errors
//        [[NSFileManager defaultManager] removeItemAtURL:photo.path error:nil];
//        
//        [_allPhotos removeObject:photo];
//    }
//    @finally
//    {
//        [_arrayLock unlock];
//    }
}

-(void)movePhoto:(id<OPPhoto>)photo toAlbum:(OPPhotoAlbum *)album
{
//    NSURL *url = [[album path] URLByAppendingPathComponent:[photo.path lastPathComponent]];
//    [[NSFileManager defaultManager] moveItemAtURL:photo.path toURL:url error:nil];
//    
//    [_photoManager collectionUpdated:self];
//    [_photoManager collectionUpdated:album];
}

-(NSArray*)findAllPhotos
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:_path includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *error) {
                                             NSLog(@"error: %@", error.userInfo);
                                             return YES;
                                         }];
    
    for (NSURL *url in enumerator)
    {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error])
        {
            //TODO handle error
        }
        else if (![isDirectory boolValue])
        {
            NSString *filePath = [url path];
            CFStringRef fileExtension = (__bridge CFStringRef) [filePath pathExtension];
            CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
            
            if (UTTypeConformsTo(fileUTI, kUTTypeImage))
            {
                OPLocalPhoto *photo = [[OPLocalPhoto alloc] initWithTitle:[filePath lastPathComponent] path:url album:self];
                [photos addObject:photo];
            }
        }
    }
    
    
    return photos;
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPPhotoAlbum *otherAlbum = object;
    return [self.path isEqual:otherAlbum.path];
}

-(NSUInteger)hash
{
    return self.path.hash;
}

@end
