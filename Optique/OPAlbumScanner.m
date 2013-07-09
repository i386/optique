//
//  OPAlbumScanner.m
//  Optique
//
//  Created by James Dumay on 29/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAlbumScanner.h"
#import "OPPhotoAlbum.h"

/** Events **/
NSString *const OPAlbumScannerDidStartScanNotification = @"OPAlbumScannerDidStartScanNotification";
NSString *const OPAlbumScannerDidFinishScanNotification = @"OPAlbumScannerDidFinishScanNotification";
NSString *const OPAlbumScannerDidFindAlbumsNotification = @"OPAlbumScannerDidFindAlbumsNotification";

@implementation OPAlbumScanner

-(id)initWithPhotoManager:(XPPhotoManager *)photoManager
{
    self = [super init];
    if (self)
    {
        _scanningQueue = [[NSOperationQueue alloc] init];
        [_scanningQueue setMaxConcurrentOperationCount:1];
        _photoManager = photoManager;
    }
    return self;
}

- (void)URLWatcher:(CDEvents *)URLWatcher eventOccurred:(CDEvent *)event
{
    if (event.isCreated || event.isRemoved || event.isRenamed)
    {
//        [self startScanAtURL:[_events.watchedURLs lastObject]];
    }
}

-(void)scanAtURL:(NSURL *)url
{
    _events = [[CDEvents alloc] initWithURLs:@[url] delegate:self];
    [self startScanAtURL:url];
}

-(void)startScanAtURL:(NSURL *)url
{
    [_scanningQueue addOperationWithBlock:^
     {
         if (_stopScan) return;
         
         [[NSNotificationCenter defaultCenter] postNotificationName:OPAlbumScannerDidStartScanNotification object:nil userInfo:@{@"photoManager" : _photoManager}];
         NSMutableArray *albumsFound = [[NSMutableArray alloc] init];
         
         for (NSURL *albumURL in [self albumURLsForURL:url])
         {
             if (_stopScan) return;
             OPPhotoAlbum *album = [self findAlbum:albumURL];
             if (album)
             {
                 if (_stopScan) return;
                 [albumsFound addObject:album];
             }
         }
         
         if (_stopScan) return;
         
         [[NSNotificationCenter defaultCenter] postNotificationName:OPAlbumScannerDidFindAlbumsNotification object:nil userInfo:@{@"albums": albumsFound, @"photoManager": _photoManager}];
         
         if (!_stopScan)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:OPAlbumScannerDidFinishScanNotification object:nil userInfo:@{@"photoManager" : _photoManager}];
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
    NSURL *optiqueFilePath = [path URLByAppendingPathComponent:fOptiqueMetadataFileName];
    NSData *data  = [NSData dataWithContentsOfURL:optiqueFilePath];
    
    id<XPPhotoCollection> collection;
    if (data)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers error:nil];
        if (dict)
        {
            NSString *exposureId = dict[fOptiqueBundle];
            if (exposureId)
            {
                id<XPPhotoCollectionProvider> photoProvider = [OPExposureService photoCollectionProviderForBundle:exposureId];
                if (photoProvider)
                {
                    collection = [photoProvider createCollectionAtPath:path metadata:dict[fOptiqueBundleData] photoManager:_photoManager];
                }
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
