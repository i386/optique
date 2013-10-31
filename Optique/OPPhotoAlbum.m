//
//  OPPhotoAlbum.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoAlbum.h"
#import "OPLocalPhoto.h"
#import "NSURL+EqualToURL.h"
#import "NSURL+URLWithoutQuery.h"
#import "NSURL+Renamer.h"

@interface OPPhotoAlbum() {
    NSLock *_arrayLock;
    volatile NSMutableOrderedSet *_allPhotos;
}

@end

@implementation OPPhotoAlbum

-(id)initWithTitle:(NSString *)title path:(NSURL *)path photoManager:(XPPhotoManager*)photoManager
{
    self = [super init];
    if (self)
    {
        _title = title;
        _path = path;
        _photoManager = photoManager;
        _arrayLock = [[NSLock alloc] init];
        
        NSDictionary* attributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[_path path] error: NULL];
        _created = attributesDictionary[NSFileCreationDate];
    }
    return self;
}

-(NSArray *)allPhotos
{
    if (_allPhotos == nil)
    {
        [self reload];
    }
    
    [_arrayLock lock];
    @try
    {
        return [(NSArray*)_allPhotos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]]];
    }
    @finally
    {
        [_arrayLock unlock];
    }
}

-(NSArray *)photosForIndexSet:(NSIndexSet *)indexSet
{
    NSMutableArray *albums = [NSMutableArray array];
    
    [self.allPhotos enumerateObjectsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [albums addObject:obj];
    }];
    
    return albums;
}

-(id<XPPhoto>)coverPhoto
{
    id<XPPhoto> __block photo;
    [self findAllPhotosWithBlock:^BOOL(id<XPPhoto> foundPhoto) {
        photo = foundPhoto;
        return FALSE;
    }];
    return photo;
}

-(void)reload
{
    [_arrayLock lock];
    @try
    {
        _allPhotos = [NSMutableOrderedSet orderedSetWithArray:[self findAllPhotosWithBlock:^BOOL(id<XPPhoto> photo) {
            return TRUE;
        }]];
    }
    @finally
    {
        [_arrayLock unlock];
    }
}

-(XPPhotoCollectionType)collectionType
{
    return kPhotoCollectionLocal;
}

-(BOOL)hasLocalCopy
{
    return TRUE;
}

-(void)addPhoto:(id<XPPhoto>)photo withCompletion:(XPCompletionBlock)completionBlock
{
    NSURL *newLocation = [[self.path URLByAppendingPathComponent:photo.title] URLWithUniqueNameIfExistsAtParent];
    
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtURL:photo.url toURL:newLocation error:&error];
    
    if (completionBlock)
    {
        completionBlock(error);
    }
    
    [self.photoManager collectionUpdated:self];
    [photo.collection.photoManager collectionUpdated:photo.collection];
}


-(void)deletePhoto:(id<XPPhoto>)photo withCompletion:(XPCompletionBlock)completionBlock
{
    NSError *error;
    NSURL *url = [self.path URLByAppendingPathComponent:photo.title];
    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    
    if (completionBlock)
    {
        completionBlock(error);
    }
    
    [self.photoManager collectionUpdated:self];
    [photo.collection.photoManager collectionUpdated:photo.collection];
}

-(NSArray*)findAllPhotosWithBlock:(BOOL (^)(id<XPPhoto>))block;
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:_path includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *error) {
                                             
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
                if (block(photo))
                {
                    [photos addObject:photo];
                }
                else
                {
                    break;
                }
            }
            
            CFRelease(fileUTI);
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
    return [[[self path] URLWithoutQuery] isEqualToURL:[otherAlbum.path URLWithoutQuery]];
}

-(NSUInteger)hash
{
    return self.path.URLWithoutQuery.hash;
}

@end
