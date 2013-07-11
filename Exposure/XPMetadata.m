//
//  XPMetadata.m
//  Optique
//
//  Created by James Dumay on 10/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "XPMetadata.h"

#define fOptiqueBundle              @"bundle"
#define fOptiqueBundleData          @"bundle_data"
#define fOptiqueMetadataFileName    @".optique"

@interface XPMetadata()

@property (readonly, strong) NSURL *path;

@end

@implementation XPMetadata

+(XPMetadata *)metadataForPath:(NSURL *)collectionPath
{
    return [[XPMetadata alloc] initWithCollectionPath:collectionPath bundleId:nil];
}

+(XPMetadata *)createMetadataForPath:(NSURL *)collectionPath bundleId:(NSString *)bundleId
{
    return [[XPMetadata alloc] initWithCollectionPath:collectionPath bundleId:bundleId];
}

-initWithCollectionPath:(NSURL*)collectionPath bundleId:(NSString*)bundleId
{
    self = [super init];
    if (self)
    {
        _bundleId = bundleId;
        _path = collectionPath;
        _bundleData = [NSMutableDictionary dictionary];
        
        NSURL *optiqueFilePath = [_path URLByAppendingPathComponent:fOptiqueMetadataFileName];
        NSData *data  = [NSData dataWithContentsOfURL:optiqueFilePath];
        
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
    return self;
}

-(void)write
{
    NSURL *optiqueFilePath = [_path URLByAppendingPathComponent:fOptiqueMetadataFileName];
    NSDictionary *dict = @{fOptiqueBundle: self.bundleId, fOptiqueBundleData: self.bundleData};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [data writeToURL:optiqueFilePath atomically:YES];
}

@end
