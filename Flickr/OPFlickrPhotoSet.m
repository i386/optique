//
//  OPFlickrPhotoSet.m
//  Optique
//
//  Created by James Dumay on 6/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFlickrPhotoSet.h"
#import "OPFlickrPhoto.h"

@interface OPFlickrPhotoSet()

@property (strong) NSString *title;
@property (strong) NSDate *created;
@property (strong) XPPhotoManager *photoManager;
@property (strong) NSMutableArray *photos;

@end

@implementation OPFlickrPhotoSet

-(id)initWithDictionary:(NSDictionary *)dict photoManager:(XPPhotoManager*)photoManager
{
    self = [super init];
    if (self)
    {
        _photoManager = photoManager;
        _flickrId = dict[@"id"] ;
        _created = [NSDate dateWithTimeIntervalSince1970:(NSUInteger)dict[@"date_create"]];
        id possibleTitle = dict[@"title"];
        
        if ([possibleTitle isKindOfClass:[NSDictionary class]])
        {
            _title = possibleTitle[@"_content"];
        }
        else if (possibleTitle != nil)
        {
            _title = dict[@"title"];
        }
        
        _photos = [NSMutableArray array];
        
        NSArray *photoMetadataDicts = dict[@"photos"];
        if (photoMetadataDicts && [photoMetadataDicts isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *photoMetadata in photoMetadataDicts)
            {
                OPFlickrPhoto *photo = [[OPFlickrPhoto alloc] initWithDictionary:photoMetadata photoSet:self];
                [_photos addObject:photo];
            }
        }
    }
    return self;
}

-(NSDictionary *)metadata
{
    NSString *dateAsString = [[[NSDateFormatter alloc] init] stringFromDate:_created];
    return @{@"id": _flickrId, @"title": _title, @"date_create": dateAsString};
}

-(NSArray *)allPhotos
{
    return _photos;
}

-(void)addPhoto:(OPFlickrPhoto *)photo
{
    [_photos addObject:photo];
}

-(NSURL *)path
{
    return [_photoManager.path URLByAppendingPathComponent:self.title];
}

-(NSArray *)photosForIndexSet:(NSIndexSet *)indexSet
{
    NSMutableArray *photos = [NSMutableArray array];
    
    [self.allPhotos enumerateObjectsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         [photos addObject:obj];
     }];
    
    return photos;
}

-(id<XPPhoto>)coverPhoto
{
    if (_photos.count > 0)
    {
        return _photos[0];
    }
    return nil;
}

-(XPPhotoCollectionType)collectionType
{
    return kPhotoCollectionOther;
}

-(void)reload
{
    //TODO: load collection
}

-(void)addPhoto:(id<XPPhoto>)photo withCompletion:(XPCompletionBlock)completionBlock
{
    NSLog(@"Flickr TODO: addPhoto:completionBlock");
}

-(void)deletePhoto:(id<XPPhoto>)photo withCompletion:(XPCompletionBlock)completionBlock
{
    NSLog(@"Flickr TODO: deletePhoto:completionBlock");
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPFlickrPhotoSet *otherSet = object;
    return [self.flickrId isEqual:otherSet.flickrId];
}

-(NSUInteger)hash
{
    return self.flickrId.hash;
}

@end
