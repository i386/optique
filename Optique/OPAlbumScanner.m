//
//  OPAlbumScanner.m
//  Optique
//
//  Created by James Dumay on 29/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAlbumScanner.h"
#import "OPPhotoAlbum.h"
#import "OPLocalPlugin.h"

#import <Exposure/Exposure.h>

@implementation OPAlbumScanner

-initWithPhotoManager:(XPPhotoManager*)photoManager plugin:(OPLocalPlugin*)plugin;
{
    self = [super init];
    if (self)
    {
        _scanningQueue = [[NSOperationQueue alloc] init];
        [_scanningQueue setMaxConcurrentOperationCount:1];
        _photoManager = photoManager;
        _plugin = plugin;
    }
    return self;
}

- (void)URLWatcher:(CDEvents *)URLWatcher eventOccurred:(CDEvent *)event
{
    if (event.isCreated || event.isRemoved || event.isRenamed)
    {
        NSLog(@"Detected fs change at '%@'. Will scan for new albums.", [_events.watchedURLs lastObject]);
        [self startScanAtURL:[_events.watchedURLs lastObject]];
    }
}

-(void)startScan
{
    _events = [[CDEvents alloc] initWithURLs:@[_photoManager.path] delegate:self];
    [self startScanAtURL:_photoManager.path];
}

-(void)startScanAtURL:(NSURL *)url
{
    [_scanningQueue addOperationWithBlock:^
     {
         if (_stopScan) return;
         
         for (NSURL *albumURL in [self albumURLsForURL:url])
         {
             if (_stopScan) return;
             OPPhotoAlbum *album = [self findAlbum:albumURL];
             if (album)
             {
                 if (_stopScan) return;
                 [_plugin didAddAlbum:album];
             }
         }
     }];
}

-(OPPhotoAlbum*)findAlbum:(NSURL*)url
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
        
        if (!UTTypeConformsTo(fileUTI, kUTTypeDirectory))
        {
            return [self resolveCollectionForPath:url];
        }
    }
    return nil;
}

-(id<XPPhotoCollection>)resolveCollectionForPath:(NSURL*)path
{
    XPBundleMetadata *metadata = [XPBundleMetadata metadataForPath:path];
    
    id<XPPhotoCollection> collection;
    if (metadata)
    {
        if (metadata.bundleId)
        {
            id<XPPhotoCollectionProvider> photoProvider = [XPExposureService photoCollectionProviderForBundle:metadata.bundleId];
            if (photoProvider)
            {
                collection = [photoProvider createCollectionAtPath:path metadata:metadata.bundleData photoManager:_photoManager];
            }
        }
    }
    
    if (!collection)
    {
        collection = [[OPPhotoAlbum alloc] initWithTitle:[path lastPathComponent] path:path photoManager:_photoManager];
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
