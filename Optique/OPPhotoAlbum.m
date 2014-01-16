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
#import "NSObject+PerformBlock.h"

typedef void (^XPPhotoSearch)(id, BOOL*);

@interface OPPhotoAlbum() {
    NSLock *_arrayLock;
    NSMutableOrderedSet *_allPhotos;
}

@property (nonatomic) BOOL loading;

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
        _allPhotos = [NSMutableOrderedSet orderedSet];
        
        NSDictionary* attributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[_path path] error: NULL];
        _created = attributesDictionary[NSFileCreationDate];
    }
    return self;
}

-(NSOrderedSet *)allPhotos
{
    return _allPhotos;
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
    __block id<XPPhoto> photo =  [_allPhotos firstObject];
    if (!photo)
    {
        [self searchDirectoryForPhotos:^(id foundPhoto, BOOL *shouldStop) {
            photo = foundPhoto;
            *shouldStop = YES;
        }];
    }
    return photo;
}

-(void)reload
{
    if (!_loading)
    {
        _loading = YES;
        
        [self performBlockInBackground:^{
            [self updatePhotos];
            _loading = NO;
        }];
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
    
    [self.photoManager collectionUpdated:self reload:YES];
    [photo.collection.photoManager collectionUpdated:photo.collection reload:YES];
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
    
    [self.photoManager collectionUpdated:self reload:YES];
    [photo.collection.photoManager collectionUpdated:photo.collection reload:YES];
}

-(void)updatePhotos
{
    [self performBlockOnMainThreadAndWaitUntilDone:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:XPPhotoCollectionDidStartLoading object:nil userInfo:@{@"collection": self}];
    }];
    
    NSMutableOrderedSet *photos = [NSMutableOrderedSet orderedSet];
    
    [self searchDirectoryForPhotos:^(id photo, BOOL *shouldStop) {
        [photos addObject:photo];
    }];
    
    [self performBlockOnMainThreadAndWaitUntilDone:^{
        _allPhotos = photos;
        [self.photoManager collectionUpdated:self reload:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:XPPhotoCollectionDidStopLoading object:nil userInfo:@{@"collection": self}];
    }];
}

-(void)searchDirectoryForPhotos:(XPPhotoSearch)block
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:_path includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *error) {
                                             
                                             return YES;
                                         }];
    
    NSUInteger count = 0;
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
            count++;
            
            NSString *filePath = [url path];
            CFStringRef fileExtension = (__bridge CFStringRef) [filePath pathExtension];
            CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
            
            BOOL shouldStop = NO;
            OPLocalPhoto *photo;
            
            XPPhotoType type = XPPhotoTypeFromUTICFString(fileUTI);
            if (type != XPPhotoTypeUnknown)
            {
                photo = [[OPLocalPhoto alloc] initWithTitle:[filePath lastPathComponent] path:url album:self type:type];
                block(photo, &shouldStop);
            }
            
            CFRelease(fileUTI);
            
            if (shouldStop)
            {
                break;
            }
        }
    }
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
