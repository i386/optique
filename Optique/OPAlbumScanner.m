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
#import "OPPhoto.h"

/** Events **/
NSString *const OPAlbumScannerDidStartScanNotification = @"OPAlbumScannerDidStartScanNotification";
NSString *const OPAlbumScannerDidFinishScanNotification = @"OPAlbumScannerDidFinishScanNotification";
NSString *const OPAlbumScannerDidFindAlbumsNotification = @"OPAlbumScannerDidFindAlbumsNotification";
NSString *const OPAlbumScannerDidFindAlbumNotification = @"OPAlbumScannerDidFindAlbumNotification";

@implementation OPAlbumScanner

-(id)initWithPhotoManager:(OPPhotoManager *)photoManager
{
    self = [super init];
    _scanningQueue = [[NSOperationQueue alloc] init];
    [_scanningQueue setMaxConcurrentOperationCount:1]; //TODO: make this scale based on cores and hdd type?
    
    _thumbQueue = [[NSOperationQueue alloc] init];
    [_thumbQueue setMaxConcurrentOperationCount:10];
    
    _photoManager = photoManager;
    
    return self;
}

-(void)scanAtURL:(NSURL *)url
{
    _events = [[CDEvents alloc] initWithURLs:@[url] delegate:self];
    
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OPAlbumScannerDidFindAlbumsNotification object:nil userInfo:@{@"count": [NSNumber numberWithInteger:albumsFound.count], @"photoManager" : _photoManager}];
        
        
        for (OPPhotoAlbum *album in albumsFound)
        {
            if (_stopScan) return;
            [self thumbAlbum:album];
        }
        
        if (_stopScan) return;
        
        [_scanningQueue addOperationWithBlock:^
        {
            if (!_stopScan)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:OPAlbumScannerDidFinishScanNotification object:nil userInfo:@{@"photoManager" : _photoManager}];
            }
        }];
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
            return [[OPPhotoAlbum alloc] initWithTitle:[filePath lastPathComponent] path:url];
        }
    }
    return nil;
}

-(void)thumbAlbum:(OPPhotoAlbum *)album
{
    [_thumbQueue addOperationWithBlock:^
    {
        for (OPPhoto *photo in album.allPhotos)
        {
            [[OPImageCache sharedPreviewCache] cacheImageForPath:photo.path];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OPAlbumScannerDidFindAlbumNotification object:nil userInfo:@{@"album": album, @"photoManager": _photoManager}];
    }];
}   

- (void)URLWatcher:(CDEvents *)URLWatcher eventOccurred:(CDEvent *)event
{
    NSLog(@"TODO: album content changes");
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
