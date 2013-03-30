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
        [[NSNotificationCenter defaultCenter] postNotificationName:OPAlbumScannerDidStartScanNotification object:nil];
        NSMutableArray *albumsFound = [[NSMutableArray alloc] init];
        
        for (NSURL *albumURL in [self albumURLsForURL:url])
        {
            OPPhotoAlbum *album = [self findAlbum:albumURL];
            if (album)
            {
                [albumsFound addObject:album];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OPAlbumScannerDidFindAlbumsNotification object:nil userInfo:@{@"count": [NSNumber numberWithInteger:albumsFound.count]}];
        
        for (OPPhotoAlbum *album in albumsFound)
        {
            [self thumbAlbum:album];
        }
        
        [_scanningQueue addOperationWithBlock:^
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:OPAlbumScannerDidFinishScanNotification object:nil];
        }];
    }];
}

-(OPPhotoAlbum*)findAlbum:(NSURL*)url
{
    NSError *error;
    NSNumber *isDirectory = nil;
    if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error])
    {
        // handle error
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OPAlbumScannerDidFindAlbumNotification object:nil userInfo:@{@"album": album}];
    }];
}   

- (void)URLWatcher:(CDEvents *)URLWatcher eventOccurred:(CDEvent *)event
{
    NSURL *url = [[URLWatcher watchedURLs] lastObject];
    
    OPPhotoAlbum *album = [self findAlbum:url];
    if (album)
    {
        [self thumbAlbum:album];
    }
    else
    {
        NSLog(@"TODO: album content changes");
    }
}

-(BOOL)hasAlbumForURL:(NSURL*)url
{
    for (NSURL *URL in [self albumURLsForURL:url])
    {
        for (OPPhotoAlbum *album in _photoManager.allAlbums)
        {
            if ([URL isEqual:album.path])
            {
                
            }
        }
    }
    return NO;
}

-(NSEnumerator*)albumURLsForURL:(NSURL*)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:url includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
                                             return YES;
                                         }];
    
    return enumerator;
}

@end
