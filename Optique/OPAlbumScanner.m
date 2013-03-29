//
//  OPAlbumScanner.m
//  Optique
//
//  Created by James Dumay on 29/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAlbumScanner.h"
#import "OPPhotoAlbum.h"
#import "OPPhoto.h"

NSString *const OPAlbumScannerDidStartScanNotification = @"OPAlbumScannerDidStartScanNotification";

NSString *const OPAlbumScannerDidFinishScanNotification = @"OPAlbumScannerDidFinishScanNotification";

NSString *const OPAlbumScannerDidFindAlbumsNotification = @"OPAlbumScannerDidFindAlbumsNotification";

NSString *const OPAlbumScannerDidFindAlbumNotification = @"OPAlbumScannerDidFindAlbumNotification";

@implementation OPAlbumScanner

-(id)init
{
    self = [super init];
    _scanningQueue = [[NSOperationQueue alloc] init];
    [_scanningQueue setMaxConcurrentOperationCount:1]; //TODO: make this scale based on cores and hdd type?
    
    _thumbQueue = [[NSOperationQueue alloc] init];
    [_thumbQueue setMaxConcurrentOperationCount:10];
    
    return self;
}

-(void)scanAtURL:(NSURL *)url
{
    [_scanningQueue addOperationWithBlock:^
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:OPAlbumScannerDidStartScanNotification object:nil];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSDirectoryEnumerator *enumerator = [fileManager
                                             enumeratorAtURL:url includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                 return YES;
                                             }];
        
        NSMutableArray *albumsFound = [[NSMutableArray alloc] init];
        
        for (NSURL *url in enumerator)
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
                    OPPhotoAlbum *album = [[OPPhotoAlbum alloc] initWithTitle:[filePath lastPathComponent] path:url];
                    [albumsFound addObject:album];
                }
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

@end
