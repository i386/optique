//
//  OPAlbumScanner.m
//  Optique
//
//  Created by James Dumay on 29/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAlbumScanner.h"
#import "OPPhotoManager.h"
#import "OPPhotoAlbum.h"

/** Events **/
NSString *const OPAlbumScannerDidStartScanNotification = @"OPAlbumScannerDidStartScanNotification";
NSString *const OPAlbumScannerDidFinishScanNotification = @"OPAlbumScannerDidFinishScanNotification";
NSString *const OPAlbumScannerDidFindAlbumsNotification = @"OPAlbumScannerDidFindAlbumsNotification";

@implementation OPAlbumScanner

-(id)initWithPhotoManager:(OPPhotoManager *)photoManager cameraService:(OPCameraService *)cameraService
{
    self = [super init];
    if (self)
    {
        _scanningQueue = [[NSOperationQueue alloc] init];
        [_scanningQueue setMaxConcurrentOperationCount:1];
        _photoManager = photoManager;
        _cameraService = cameraService;
    }
    return self;
}

- (void)URLWatcher:(CDEvents *)URLWatcher eventOccurred:(CDEvent *)event
{
    if (event.isCreated || event.isRemoved || event.isRenamed)
    {
        [self startScanAtURL:[_events.watchedURLs lastObject]];
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
         
         //TODO: this really shouldn't be here because technically its not a 'album'. What we *should* be doing is filtering it before we remove it in OPPhotoManager when OPAlbumScannerDidFindAlbumsNotification is responded to. No one is perfect.
         [albumsFound addObjectsFromArray:_cameraService.allCameras];
         
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
            return [[OPPhotoAlbum alloc] initWithTitle:[filePath lastPathComponent] path:url photoManager:_photoManager];
        }
    }
    return nil;
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
