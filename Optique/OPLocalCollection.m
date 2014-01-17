//
//  OPPhotoAlbum.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPLocalCollection.h"
#import "OPLocalItem.h"
#import "NSURL+EqualToURL.h"
#import "NSURL+URLWithoutQuery.h"
#import "NSURL+Renamer.h"
#import "NSObject+PerformBlock.h"

typedef void (^XPItemSearch)(id, BOOL*);

@interface OPLocalCollection() {
    NSLock *_arrayLock;
    NSMutableOrderedSet *_allItems;
}

@property (nonatomic) BOOL loading;

@end

@implementation OPLocalCollection

-(id)initWithTitle:(NSString *)title path:(NSURL *)path collectionManager:(XPCollectionManager*)collectionManager
{
    self = [super init];
    if (self)
    {
        _title = title;
        _path = path;
        _collectionManager = collectionManager;
        _arrayLock = [[NSLock alloc] init];
        _allItems = [NSMutableOrderedSet orderedSet];
        
        NSDictionary* attributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[_path path] error: NULL];
        _created = attributesDictionary[NSFileCreationDate];
    }
    return self;
}

-(NSOrderedSet *)allItems
{
    return _allItems;
}

-(NSArray *)itemsAtIndexes:(NSIndexSet *)indexSet
{
    NSMutableArray *albums = [NSMutableArray array];
    
    [self.allItems enumerateObjectsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [albums addObject:obj];
    }];
    
    return albums;
}

-(id<XPItem>)coverItem
{
    __block id<XPItem> item =  [_allItems firstObject];
    if (!item)
    {
        [self searchDirectoryForItems:^(id foundPhoto, BOOL *shouldStop) {
            item = foundPhoto;
            *shouldStop = YES;
        }];
    }
    return item;
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

-(XPItemCollectionType)collectionType
{
    return XPItemCollectionLocal;
}

-(BOOL)hasLocalCopy
{
    return TRUE;
}

-(void)addPhoto:(id<XPItem>)item withCompletion:(XPCompletionBlock)completionBlock
{
    NSURL *newLocation = [[self.path URLByAppendingPathComponent:item.title] URLWithUniqueNameIfExistsAtParent];
    
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtURL:item.url toURL:newLocation error:&error];
    
    if (completionBlock)
    {
        completionBlock(error);
    }
    
    [self.collectionManager collectionUpdated:self reload:YES];
    [item.collection.collectionManager collectionUpdated:item.collection reload:YES];
}


-(void)deletePhoto:(id<XPItem>)item withCompletion:(XPCompletionBlock)completionBlock
{
    NSError *error;
    NSURL *url = [self.path URLByAppendingPathComponent:item.title];
    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    
    if (completionBlock)
    {
        completionBlock(error);
    }
    
    [self.collectionManager collectionUpdated:self reload:YES];
    [item.collection.collectionManager collectionUpdated:item.collection reload:YES];
}

-(void)updatePhotos
{
    [self performBlockOnMainThreadAndWaitUntilDone:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:XPPhotoCollectionDidStartLoading object:nil userInfo:@{@"collection": self}];
    }];
    
    NSMutableOrderedSet *items = [NSMutableOrderedSet orderedSet];
    
    [self searchDirectoryForItems:^(id item, BOOL *shouldStop) {
        [items addObject:item];
    }];
    
    [self performBlockOnMainThreadAndWaitUntilDone:^{
        _allItems = items;
        [self.collectionManager collectionUpdated:self reload:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:XPPhotoCollectionDidStopLoading object:nil userInfo:@{@"collection": self}];
    }];
}

-(void)searchDirectoryForItems:(XPItemSearch)block
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
            OPLocalItem *item;
            
            XPItemType type = XPItemTypeFromUTICFString(fileUTI);
            if (type != XPItemTypeUnknown)
            {
                item = [[OPLocalItem alloc] initWithTitle:[filePath lastPathComponent] path:url album:self type:type];
                block(item, &shouldStop);
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
    
    OPLocalCollection *otherAlbum = object;
    return [[[self path] URLWithoutQuery] isEqualToURL:[otherAlbum.path URLWithoutQuery]];
}

-(NSUInteger)hash
{
    return self.path.URLWithoutQuery.hash;
}

@end
