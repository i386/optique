//
//  OPFlickrPhotoSet.m
//  Optique
//
//  Created by James Dumay on 6/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFlickrPhotoSet.h"

@interface OPFlickrPhotoSet()

@property (strong) NSString *title;
@property (strong) NSDate *created;
@property (strong) XPPhotoManager *photoManager;

@end

@implementation OPFlickrPhotoSet

-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        _created = [NSDate dateWithTimeIntervalSince1970:(NSUInteger)dict[@"date_create"]];
        _title = dict[@"title"][@"_content"];
    }
    return self;
}

-(NSArray *)allPhotos
{
    return nil;
}

-(NSArray *)photosForIndexSet:(NSIndexSet *)indexSet
{
    return nil;
}

-(id<XPPhoto>)coverPhoto
{
    return nil;
}

-(BOOL)isStoredOnFileSystem
{
    return NO;
}

-(void)reload
{
}

-(void)addPhoto:(id<XPPhoto>)photo withCompletion:(XPCompletionBlock)completionBlock
{
    
}

-(void)deletePhoto:(id<XPPhoto>)photo withCompletion:(XPCompletionBlock)completionBlock
{
    
}

@end
