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
#import "NSURL+UnrollToParent.h"

@interface OPCollectionWatcher ()

@property (weak) XPCollectionManager *collectionManager;
@property (weak) OPLocalPlugin *plugin;

@property (strong) CDEvents *rootWatch;
@property (strong) NSOperationQueue *scanningQueue;

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
    }
    return self;
}

-(void)startWatching
{
    _rootWatch = [[CDEvents alloc] initWithURLs:@[self.collectionManager.path]
                                          block:^(CDEvents *watcher, CDEvent *event) {
                                              
                                              NSURL *collectionDirectory = [NSURL fileURLWithPath:self.collectionManager.path.path isDirectory:YES];
                                              
                                              //File changed in the top level
                                              if ([event.URL isEqualTo:collectionDirectory] && (event.isCreated || event.isRemoved || event.isRenamed))
                                              {
                                                  [self scanForNewCollections];
                                              }
                                              
                                              //A sub directory changed
                                              if (![event.URL isEqualTo:collectionDirectory])
                                              {
                                                  NSURL *collectionURL = [event.URL unrollToParent:collectionDirectory];
                                                  NSLog(@"Collection changed '%@'", collectionURL);
                                                  
                                                  id<XPItemCollection> collection = [_plugin collectionForURL:collectionURL];
                                                  if (collection && [collection respondsToSelector:@selector(reload)])
                                                  {
                                                      [_collectionManager collectionUpdated:collection reload:YES];
                                                  }
                                              }
                                          }
                                      onRunLoop:[NSRunLoop currentRunLoop]
                           sinceEventIdentifier:kCDEventsSinceEventNow
                           notificationLantency:1
                        ignoreEventsFromSubDirs:NO
                                    excludeURLs:nil
                            streamCreationFlags:kCDEventsDefaultEventStreamFlags];
    
    NSLog(@"Watching for collections '%@'", self.collectionManager.path.path);
}

-(void)stopWatching
{
    [_scanningQueue setSuspended:YES];
    [_scanningQueue cancelAllOperations];
}

-(void)scanForNewCollections
{
    NSLog(@"scanning for new collections at '%@'", self.collectionManager.path.path);
    
    [_scanningQueue addOperationWithBlock:^{
        
        NSMutableArray *collections = [NSMutableArray array];
        for (NSURL *url in [self collectionURLs:self.collectionManager.path])
        {
            id<XPItemCollection> collection = [self collectionForURL:url];
            if (collection)
            {
                [collections addObject:collection];
            }
        }
        [_plugin didAddCollections:collections];
    }];
}

-(NSEnumerator*)collectionURLs:(NSURL*)url
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
