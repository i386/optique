//
//  OPBundleLoader.m
//  Optique
//
//  Created by James Dumay on 5/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "XPExposureService.h"
#import <BlocksKit/BlocksKit.h>

@implementation XPExposureService

+(XPExposureService *)defaultLoader
{
    static dispatch_once_t pred;
    static XPExposureService *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[XPExposureService alloc] init];
        [shared loadExposures];
    });
    
    return shared;
}

+(id<XPPlugin>)pluginForBundle:(NSString *)bundleId
{
    return [[[XPExposureService defaultLoader] exposures] objectForKey:bundleId];
}

+(id<XPPhotoCollectionProvider>)photoCollectionProviderForBundle:(NSString *)bundleId
{
    id<XPPlugin> plugin = [XPExposureService pluginForBundle:bundleId];
    if (plugin != nil && [plugin conformsToProtocol:@protocol(XPPhotoCollectionProvider)])
    {
        return (id<XPPhotoCollectionProvider>)plugin;
    }
    return nil;
}

+(void)loadPlugins:(NSDictionary*)userInfo
{
    [[[XPExposureService defaultLoader] exposures] each:^(NSString *pluginKey, id pluginInstance) {
        if ([pluginInstance respondsToSelector:@selector(pluginDidLoad:)])
        {
            @try
            {
                [pluginInstance pluginDidLoad:userInfo];
            }
            @catch (NSException *exception)
            {
                NSLog(@"Could not load plugin '%@'\nReason:\n%@", pluginKey, exception);
            }
        }
    }];
}

+(void)unloadPlugins:(NSDictionary*)userInfo
{
    [[[XPExposureService defaultLoader] exposures] each:^(NSString *pluginKey, id pluginInstance) {
        if ([pluginInstance respondsToSelector:@selector(pluginWillUnload:)])
        {
            @try
            {
                [pluginInstance pluginWillUnload:userInfo];
            }
            @catch (NSException *exception)
            {
                NSLog(@"Could not unload plugin '%@' cleanly\nReason:\n%@", pluginKey, exception);
            }
        }
    }];
}

+(void)photoManagerWasCreated:(XPPhotoManager *)photoManager
{
    [[XPExposureService respondsToPhotoManagerWasCreated] each:^(id sender) {
        [sender photoManagerWasCreated:photoManager];
    }];
}

+(void)photoManager:(XPPhotoManager*)photoManager collectionViewController:(id<XPCollectionViewController>)controller
{
    [[XPExposureService respondsToCollectionViewController] each:^(id<XPPlugin> sender) {
        [sender photoManager:photoManager collectionViewController:controller];
    }];
}

+(void)photoManager:(XPPhotoManager*)photoManager photoCollectionViewController:(id<XPPhotoCollectionViewController>)controller
{
    [[XPExposureService respondsToPhotoCollectionViewController] each:^(id<XPPlugin> sender) {
        [sender photoManager:photoManager photoCollectionViewController:controller];
    }];
}

+(void)photoManager:(XPPhotoManager*)photoManager photoController:(id<XPPhotoController>)controller
{
    [[XPExposureService respondsToPhotoViewController] each:^(id<XPPlugin> sender) {
        [sender photoManager:photoManager photoController:controller];
    }];
}

+(id<XPPhotoCollection>)createCollectionWithTitle:(NSString *)title path:(NSURL *)path
{
    id localPlugin = [XPExposureService pluginForBundle:@"com.whimsy.optique.Local"];
    if (!localPlugin)
    {
        NSLog(@"Could not find local plugin");
    }
    return [localPlugin createCollectionWithTitle:title path:path];
}

+(NSSet *)photoCollectionProviders
{
    return [XPExposureService conformsToPhotoCollectionProvider];
}

+(NSArray *)debugMenuItems
{
    NSMutableArray *debugMenuItems = [NSMutableArray array];
    
    [[[XPExposureService defaultLoader] exposures] each:^(NSString *name, id<XPPlugin> plugin) {
        if ([plugin respondsToSelector:@selector(debugMenuItems)])
        {
            NSMenuItem *subMenuItem = [[NSMenuItem alloc] initWithTitle:name action:nil keyEquivalent:@""];
            [debugMenuItems addObject:subMenuItem];
            [debugMenuItems addObjectsFromArray:[plugin debugMenuItems]];
            [debugMenuItems addObject:[NSMenuItem separatorItem]];
        }
    }];
    return debugMenuItems;
}


+(NSSet *)conformsToPhotoCollectionProvider
{
    NSSet *exposures = [NSMutableSet setWithArray:[[XPExposureService defaultLoader] exposures].allValues];
    
    return [exposures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject conformsToProtocol:@protocol(XPPhotoCollectionProvider)];
    }]];
}

+(NSSet *)respondsToPhotoManagerWasCreated
{
    NSSet *exposures = [NSMutableSet setWithArray:[[XPExposureService defaultLoader] exposures].allValues];
    
    return [exposures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPlugin> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject respondsToSelector:@selector(photoManagerWasCreated:)];
    }]];
}

+(NSSet *)respondsToCollectionViewController
{
    NSSet *exposures = [NSMutableSet setWithArray:[[XPExposureService defaultLoader] exposures].allValues];
    
    return [exposures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPlugin> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject respondsToSelector:@selector(photoManager:collectionViewController:)];
    }]];
}

+(NSSet *)respondsToPhotoCollectionViewController
{
    NSSet *exposures = [NSMutableSet setWithArray:[[XPExposureService defaultLoader] exposures].allValues];
    
    return [exposures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPlugin> evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject respondsToSelector:@selector(photoManager:photoCollectionViewController:)];
    }]];
}

+(NSSet *)respondsToPhotoViewController
{
    NSSet *exposures = [NSMutableSet setWithArray:[[XPExposureService defaultLoader] exposures].allValues];
    
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
