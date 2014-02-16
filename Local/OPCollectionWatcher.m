//
//  OPCollectionWatcher.m
//  Optique
//
//  Created by James Dumay on 16/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <CDEvents/CDEvents.h>

#import "OPCollectionWatcher.h"
#import "OPLocalPlugin.h"

@interface OPCollectionWatcher ()

@property (weak) XPCollectionManager *collectionManager;
@property (weak) OPLocalPlugin *plugin;

@property (strong) CDEvents *rootWatch;
@property (strong) NSOperationQueue *scanningQueue;

@property (strong) NSMutableDictionary *watchersForCollection;

@end

@implementation OPCollectionWatcher

-(id)initWithCollectionManager:(XPCollectionManager *)collectionManager plugin:(OPLocalPlugin *)plugin
{
    self = [super init];
    if (self)
    {
        _scanningQueue = [[NSOperationQueue alloc] init];
        [_scanningQueue setMaxConcurrentOperationCount:1];
        _collectionManager = collectionManager;
        _plugin = plugin;
        _watchersForCollection = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)startWatching
{
    _rootWatch = [[CDEvents alloc] initWithURLs:@[self.collectionManager.path]
                                          block:^(CDEvents *watcher, CDEvent *event) {
                                              if (event.isCreated || event.isRemoved || event.isRenamed)
                                              {
                                                  [self scanForNewCollections];
                                              }
                                          }
                                      onRunLoop:[NSRunLoop currentRunLoop]
                           sinceEventIdentifier:kCDEventsSinceEventNow
                           notificationLantency:CD_EVENTS_DEFAULT_NOTIFICATION_LATENCY
                        ignoreEventsFromSubDirs:YES
                                    excludeURLs:nil
                            streamCreationFlags:kCDEventsDefaultEventStreamFlags];
}

-(void)stopWatching
{
    [_scanningQueue setSuspended:YES];
    [_scanningQueue cancelAllOperations];
}

-(void)scanForNewCollections
{
    NSLog(@"scanning for new collections at '%@'", self.collectionManager.path);
    
    [_scanningQueue addOperationWithBlock:^{
        
        NSMutableArray *albums = [NSMutableArray array];
        for (NSURL *albumURL in [self albumURLsForURL:self.collectionManager.path])
        {
            NSURL *url = [self.collectionManager.path URLByAppendingPathComponent:[albumURL lastPathComponent]];
            
            id<XPItemCollection> collection = [self collectionForURL:url];
            if (collection)
            {
                [albums addObject:collection];
            }
        }
        
        [_plugin didAddCollections:albums];
    }];
}

-(void)startWatchingCollection:(id<XPItemCollection>)collection
{
    CDEvents *events = [[CDEvents alloc] initWithURLs:@[collection.path] block:^(CDEvents *watcher, CDEvent *event) {
        NSLog(@"received event");
    }];
    NSLog(@"started watching %@", collection.path);
    [_watchersForCollection setObject:events forKey:collection.path];
}

-(void)stopWatchingCollection:(id<XPItemCollection>)collection
{
    [_watchersForCollection removeObjectForKey:collection.path];
    NSLog(@"stopped watching %@", collection.path);
}

-(NSEnumerator*)albumURLsForURL:(NSURL*)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:url includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             NSLog(@"Error listing '%@' album: %@", url, error.userInfo);
                                             return YES;
                                         }];
    
    return enumerator;
}

-(id<XPItemCollection>)collectionForURL:(NSURL*)url
{
    NSError *error;
    NSNumber *isDirectory = nil;
    if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error])
    {
        NSLog(@"Error occured checking if URL '%@' album: %@", url, error.userInfo);
    }
    else if ([isDirectory boolValue])
    {
        NSString *filePath = [url path];
        CFStringRef fileExtension = (__bridge CFStringRef) [filePath pathExtension];
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        
        id<XPItemCollection> collection = nil;
        if (!UTTypeConformsTo(fileUTI, kUTTypeDirectory))
        {
            collection = [self resolveCollectionForPath:url];
        }
        
        if (fileUTI == NULL)
        {
            CFRelease(fileUTI);
        }
        
        return collection;
    }
    return nil;
}

-(id<XPItemCollection>)resolveCollectionForPath:(NSURL*)path
{
    XPBundleMetadata *metadata = [XPBundleMetadata metadataForPath:path];
    
    id<XPItemCollection> collection;
    if (metadata)
    {
        if (metadata.bundleId)
        {
            id<XPItemCollectionProvider> provider = [XPExposureService itemCollectionProviderForBundle:metadata.bundleId];
            if (provider)
            {
                collection = [provider createCollectionAtPath:path metadata:metadata.bundleData collectionManager:_collectionManager];
            }
        }
    }
    
    if (!collection)
    {
        collection = [[OPLocalCollection alloc] initWithTitle:[path lastPathComponent] path:path collectionManager:_collectionManager];
    }
    return collection;
}

@end
