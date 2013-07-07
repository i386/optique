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

+(void)photoManager:(XPPhotoManager*)photoManager collectionViewController:(id<XPCollectionViewController>)controller
{
    [[OPExposureService respondsToCollectionViewController] each:^(id<XPPlugin> sender) {
        [sender photoManager:photoManager collectionViewController:controller];
    }];
}

+(void)photoManager:(XPPhotoManager*)photoManager photoCollectionViewController:(id<XPPhotoCollectionViewController>)controller
{
    [[OPExposureService respondsToPhotoCollectionViewController] each:^(id<XPPlugin> sender) {
        [sender photoManager:photoManager photoCollectionViewController:controller];
    }];
}

+(void)photoManager:(XPPhotoManager*)photoManager photoController:(id<XPPhotoController>)controller
{
    [[OPExposureService respondsToPhotoViewController] each:^(id<XPPlugin> sender) {
        [sender photoManager:photoManager photoController:controller];
    }];
}

+(NSSet *)photoCollectionProviders
{
    return [OPExposureService conformsToPhotoCollectionProvider];
}

+(NSArray *)debugMenuItems
{
    NSMutableArray *debugMenuItems = [NSMutableArray array];
    
    [[[OPExposureService defaultLoader] exposures] each:^(NSString *name, id<XPPlugin> plugin) {
        if ([plugin respondsToSelector:@selector(debugMenuItems)])
        {
            [debugMenuItems addObject:[[NSMenuItem alloc] initWithTitle:name action:nil keyEquivalent:@""]];
            [debugMenuItems addObjectsFromArray:[plugin debugMenuItems]];
            [debugMenuItems addObject:[NSMenuItem separatorItem]];
        }
    }];
    return debugMenuItems;
}


+(NSSet *)conformsToPhotoCollectionProvider
{
    NSSet *exposures = [NSMutableSet setWithArray:[[OPExposureService defaultLoader] exposures].allValues];
    
    return [exposures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject conformsToProtocol:@protocol(XPPhotoCollectionProvider)];
    }]];
}

+(NSSet *)respondsToCollectionViewController
{
    NSSet *exposures = [NSMutableSet setWithArray:[[OPExposureService defaultLoader] exposures].allValues];
    
    return [exposures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPlugin> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject respondsToSelector:@selector(photoManager:collectionViewController:)];
    }]];
}

+(NSSet *)respondsToPhotoCollectionViewController
{
    NSSet *exposures = [NSMutableSet setWithArray:[[OPExposureService defaultLoader] exposures].allValues];
    
    return [exposures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPlugin> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject respondsToSelector:@selector(photoManager:photoCollectionViewController:)];
    }]];
}

+(NSSet *)respondsToPhotoViewController
{
    NSSet *exposures = [NSMutableSet setWithArray:[[OPExposureService defaultLoader] exposures].allValues];
    
    return [exposures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPlugin> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject respondsToSelector:@selector(photoManager:photoController:)];
    }]];
}

-(void)loadExposures
{
    NSMutableDictionary *exposures = [[NSMutableDictionary alloc] init];
    
    NSString *pluginPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/PlugIns/"];

#if DEBUG
    NSLog(@"Exposure plugin path '%@'", pluginPath);
#endif
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:pluginPath];
    
    for (NSString *path in enumerator)
    {
        if ([[path pathExtension] isEqualToString:@"bundle"])
        {
            NSString *pathToExposure = [pluginPath stringByAppendingPathComponent:path];
            [self loadBundle:pathToExposure exposures:exposures];
        }
    }
    
    _exposures = exposures;
}

-(void)loadBundle:(NSString*)path exposures:(NSMutableDictionary*)exposures
{
    Class pluginClass;
    id pluginInstance;
    NSBundle *bundleToLoad = [NSBundle bundleWithPath:path];
    
    //Should have a principalClass and confirm to XPPlugin
    if ((pluginClass = [bundleToLoad principalClass]) && [pluginClass conformsToProtocol:@protocol(XPPlugin)])
    {
        
#if DEBUG
        NSLog(@"Loaded Exposure plugin '%@'", pluginClass);
#endif
        
        pluginInstance = [[pluginClass alloc] init];
        [exposures setObject:pluginInstance forKey:bundleToLoad.bundleIdentifier];
    }
    else
    {
//#if DEBUG
        NSLog(@"Could not load plugin class '%@' from bundle '%@'", bundleToLoad.principalClass, bundleToLoad.bundleIdentifier);
//#endif
    }
}

@end
