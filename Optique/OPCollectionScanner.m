//
//  OPAlbumScanner.m
//  Optique
//
//  Created by James Dumay on 29/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCollectionScanner.h"

#import <CDEvents/CDEvents.h>
#import <Exposure/Exposure.h>

#import "OPLocalCollection.h"
#import "OPLocalPlugin.h"

@interface OPCollectionScanner ()

@property (readonly, strong) NSOperationQueue *scanningQueue;
@property (readonly, strong) NSOperationQueue *thumbQueue;
@property (readonly, weak) XPCollectionManager *collectionManager;
@property (readonly, weak) OPLocalPlugin *plugin;
@property (readonly, strong) CDEvents *events;
@property (readonly, strong) NSMutableDictionary *eventsForSubPath;

@end

@implementation OPCollectionScanner

-initWithCollectionManager:(XPCollectionManager*)collectionManager plugin:(OPLocalPlugin*)plugin;
{
    self = [super init];
    if (self)
    {
        _scanningQueue = [[NSOperationQueue alloc] init];
        [_scanningQueue setMaxConcurrentOperationCount:1];
        _collectionManager = collectionManager;
        _plugin = plugin;
        _eventsForSubPath = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)startScan
{
    //Only watch the top level directory for new albums
    _events = [[CDEvents alloc] initWithURLs:@[_collectionManager.path]
                                       block:^(CDEvents *watcher, CDEvent *event) {
                                           if (event.isCreated || event.isRemoved || event.isRenamed)
                                           {
                                               NSLog(@"Detected fs change at '%@'. Will scan for new albums.", [_events.watchedURLs lastObject]);
                                               [self startScanAtURL:[_events.watchedURLs lastObject]];
                                           }
                                       }
                                   onRunLoop:[NSRunLoop currentRunLoop]
                        sinceEventIdentifier:kCDEventsSinceEventNow
                        notificationLantency:CD_EVENTS_DEFAULT_NOTIFICATION_LATENCY
                     ignoreEventsFromSubDirs:YES
                                 excludeURLs:nil
                         streamCreationFlags:kCDEventsDefaultEventStreamFlags];
    
    NSLog(@"Watching %@", _events.description);
    
    [self startScanAtURL:_collectionManager.path];
}

-(void)startScanAtURL:(NSURL *)url
{
    [_scanningQueue addOperationWithBlock:^
     {
         if (_stopScan) return;
         
         NSMutableArray *albums = [NSMutableArray array];
         for (NSURL *albumURL in [self albumURLsForURL:url])
         {
             if (_stopScan) return;
             OPLocalCollection *album = [self findAlbum:albumURL];
             if (album)
             {
                 if (_stopScan) return;
                 
                 [albums addObject:album];

             }
         }
         
         [_plugin didAddAlbums:albums];
     }];
}

-(void)createWatchersForCollection:(id<XPItemCollection>)collection
{
    CDEvents *events = _eventsForSubPath[collection.path];
    if (events)
    {
        [events flushSynchronously];
    }
    
    events = [[CDEvents alloc] initWithURLs:@[collection.path] block:^(CDEvents *watcher, CDEvent *event) {
        
        NSLog(@"fsevent fired");
        
        if ([collection respondsToSelector:@selector(reload)])
        {
            [collection reload];
        }
        
    }];
    
    NSLog(@"Watching %@", events.description);
    
    [_eventsForSubPath setObject:events forKey:collection.path];
}

-(OPLocalCollection*)findAlbum:(NSURL*)url
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
        
        if (collection)
        {
            [self createWatchersForCollection:collection];
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

@end
