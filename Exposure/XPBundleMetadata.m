//
//  XPMetadata.m
//  Optique
//
//  Created by James Dumay on 10/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "XPBundleMetadata.h"

#define fOptiqueBundle              @"bundle"
#define fOptiqueBundleData          @"bundle_data"
#define fOptiqueMetadataFileName    @".optique"

@interface XPBundleMetadata()

@property (readonly, strong) NSURL *path;

@end

@implementation XPBundleMetadata

+(XPBundleMetadata *)metadataForPath:(NSURL *)collectionPath
{
    return [[XPBundleMetadata alloc] initWithCollectionPath:collectionPath bundleId:nil];
}

+(XPBundleMetadata *)createMetadataForPath:(NSURL *)collectionPath bundleId:(NSString *)bundleId
{
    return [[XPBundleMetadata alloc] initWithCollectionPath:collectionPath bundleId:bundleId];
}

-initWithCollectionPath:(NSURL*)collectionPath bundleId:(NSString*)bundleId
{
    self = [super init];
    if (self)
    {
        _bundleId = bundleId;
        _path = collectionPath;
        [self reload];
    }
    return self;
}

-(void)write
{
    NSDictionary *dict = @{fOptiqueBundle: self.bundleId, fOptiqueBundleData: self.bundleData};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [data writeToURL:[self metadataPath] atomically:YES];
}

-(void)reload
{
    _bundleData = [NSMutableDictionary dictionary];
    
    NSData *data  = [NSData dataWithContentsOfURL:[self metadataPath]];
    
    if (data)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers error:nil];
        if (dict)
        {
            NSDictionary *data = dict[fOptiqueBundleData];
            if (data)
            {
                [_bundleData addEntriesFromDictionary:data];
            }
        }
    }
}

-(NSURL*)metadataPath
{
    return [_path URLByAppendingPathComponent:fOptiqueMetadataFileName];
}

@end
