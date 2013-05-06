//
//  OPBundleLoader.m
//  Optique
//
//  Created by James Dumay on 5/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPExposureService.h"

@implementation OPExposureService

+(OPExposureService *)defaultLoader
{
    static dispatch_once_t pred;
    static OPExposureService *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[OPExposureService alloc] init];
        [shared loadExposures];
    });
    
    return shared;
}

+(void)collectionViewController:(id<XPCollectionViewController>)controller
{
    [[OPExposureService respondsToCollectionViewController] each:^(id<XPPlugin> sender) {
        [sender collectionViewController:controller];
    }];
}

+(void)photoCollectionViewController:(id<XPPhotoCollectionViewController>)controller
{
    [[OPExposureService respondsToPhotoCollectionViewController] each:^(id<XPPlugin> sender) {
        [sender photoCollectionViewController:controller];
    }];
}

+(void)photoViewController:(id<XPPhotoViewController>)controller
{
    [[OPExposureService respondsToPhotoViewController] each:^(id<XPPlugin> sender) {
        [sender photoViewController:controller];
    }];
}

+(NSSet *)respondsToCollectionViewController
{
    NSSet *exposures = [NSMutableSet setWithArray:[[OPExposureService defaultLoader] exposures].allValues];
    
    return [exposures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPlugin> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject respondsToSelector:@selector(collectionViewController:)];
    }]];
}

+(NSSet *)respondsToPhotoCollectionViewController
{
    NSSet *exposures = [NSMutableSet setWithArray:[[OPExposureService defaultLoader] exposures].allValues];
    
    return [exposures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPlugin> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject respondsToSelector:@selector(photoCollectionViewController:)];
    }]];
}

+(NSSet *)respondsToPhotoViewController
{
    NSSet *exposures = [NSMutableSet setWithArray:[[OPExposureService defaultLoader] exposures].allValues];
    
    return [exposures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPlugin> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject respondsToSelector:@selector(photoViewController:)];
    }]];
}

-(void)loadExposures
{
    NSMutableDictionary *exposures = [[NSMutableDictionary alloc] init];
    
    NSString *exposurePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/PlugIns/"];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:exposurePath];
    
    for (NSString *path in enumerator)
    {
        [self loadBundle:path exposures:exposures];
    }
    
    _exposures = exposures;
}

-(void)loadBundle:(NSString*)path exposures:(NSMutableDictionary*)exposures
{
    Class pluginClass;
    id pluginInstance;
    NSBundle *bundleToLoad = [NSBundle bundleWithPath:path];
    
    //Should have a principalClass and confirm to XPPlugin
    if ((pluginClass = [bundleToLoad principalClass]) && [pluginClass conformsToProtocol:@protocol(XPPlugin)]) {
        pluginInstance = [[pluginClass alloc] init];
        [exposures setObject:pluginInstance forKey:bundleToLoad.bundleIdentifier];
    }
}

@end
