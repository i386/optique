//
//  OPPhotoAlbum.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//


#include <sys/stat.h>
#include <sys/types.h>
#include <dirent.h>
#include <fts.h>

#import "OPPhotoAlbum.h"
#import "OPLocalPhoto.h"
#import "NSURL+EqualToURL.h"
#import "NSURL+URLWithoutQuery.h"
#import "NSURL+Renamer.h"
#import "NSObject+PerformBlock.h"

@interface OPPhotoAlbum() {
    NSLock *_arrayLock;
    NSMutableOrderedSet *_allPhotos;
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
        _allPhotos = [NSMutableOrderedSet orderedSet];
        
        NSDictionary* attributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[_path path] error: NULL];
        _created = attributesDictionary[NSFileCreationDate];
    }
    return self;
}

-(NSOrderedSet *)allPhotos
{
    if (_allPhotos.count == 0)
    {
        [self reload];
    }
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
    return [_allPhotos firstObject];
}

-(void)reload
{
    [self performBlockInBackground:^{
        [self updatePhotos];
    }];
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
    FTS *fts;
    
    fts = fts_open_b(self.path.path.UTF8String, FTS_NOCHDIR, ^int(const FTSENT ** entry1, const FTSENT ** entry2) {
        return 1;
    });
    
    if (fts)
    {
        
    }
    
//    struct dirent **namelist;
//    int n;
//    
//    n = scandir_b(self.path.path.UTF8String, &namelist, ^int(const struct dirent * dir) {
//        return 1; //Include all for the moment
//    }, ^int(const struct dirent ** dir1, const struct dirent ** dir2) {
//        return 1;
//    });
//    
//    n = scandir(self.path.path.UTF8String, &namelist, 0, alphasort);
//    if (n < 0)
//        perror("scandir");
//    else {
//        while(n--) {
//            printf("%s\n", namelist[n]->d_name);
//            
//            struct stat st;
//            stat(namelist[n]->d_name, &st);
//            int size = st.st_size;
//            
//            NSLog(@"%s, %d", namelist[n]->d_name, size);
//            
//            free(namelist[n]);
//        }
//        free(namelist);
//    }
    
    
    NSMutableOrderedSet *photos = [NSMutableOrderedSet orderedSet];
    
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
            
            if (UTTypeConformsTo(fileUTI, kUTTypeImage))
            {
                OPLocalPhoto *photo = [[OPLocalPhoto alloc] initWithTitle:[filePath lastPathComponent] path:url album:self];
                [photos addObject:photo];
                
                if (count % 1000 == 1)
                {
//                    [self.photoManager collectionUpdated:self reload:NO];
                }
            }
            
            CFRelease(fileUTI);
        }
    }
    
    __block NSMutableOrderedSet *setToRemove;
    
    
    [self performBlockOnMainThreadAndWaitUntilDone:^{
        _allPhotos = photos;
        [self.photoManager collectionUpdated:self reload:NO];
        
//        setToRemove = [NSMutableOrderedSet orderedSetWithOrderedSet:_allPhotos];
//        [setToRemove minusOrderedSet:photos];
    }];
    
//    [self performBlockOnMainThread:^{
//        [setToRemove enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            [_allPhotos removeObject:obj];
//        }];
//        
//        [self.photoManager collectionUpdated:self reload:NO];
//    }];
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
