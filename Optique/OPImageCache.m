//
//  OPImageCache.m
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImageCache.h"
#import <NSHash/NSString+NSHash.h>

#define CACHE_SIZE 524288000

@interface OPImageCache() {
    NSCache *_cache;
    NSURL *_cacheDirectory;
    NSSize _size;
}
@end

@implementation OPImageCache

static OPImageCache *_sharedPreviewCache;

+(OPImageCache *)sharedPreviewCache
{
    if (!_sharedPreviewCache)
    {
        _sharedPreviewCache = [[OPImageCache alloc] initWithIdentity:@"previews" size:kOPImageCacheThumbSize];
    }
    return _sharedPreviewCache;
}

+(NSFileManager*)newFileManager
{
    return [[NSFileManager alloc] init];
}

-(id)initWithIdentity:(NSString *)identity size:(NSSize)size
{
    self = [super init];
    _size = size;
    _cache = [[NSCache alloc] init];
    [_cache setCountLimit:CACHE_SIZE];
    
    NSFileManager *fileManager = [OPImageCache newFileManager];
    
    NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    _cacheDirectory = [[[[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"com.whimsy.optique" isDirectory:YES] URLByAppendingPathComponent:identity isDirectory:YES];
    
    return self;
}

-(NSImage*)loadImageForPath:(NSURL *)path
{
    NSURL *cachedPath = [self cachedPathForURL:path];
    NSFileManager *fileManager = [OPImageCache newFileManager];
    NSImage *image;
    NSString *stringPath = [cachedPath path];
    
    //Check if image is on file system
    if ([fileManager fileExistsAtPath:stringPath])
    {
        image = [[NSImage alloc] initByReferencingURL:cachedPath];
        [image setCacheMode:NSImageCacheNever];
        if (image)
        {
            [self addToCache:path cachedPath:cachedPath];
        }
    }
    
    //If it isn't on the filesystem cache, generate a new cached image
    if (!image)
    {
        image = [self cacheImageForPath:path];
        if (image)
        {
            [self addToCache:path cachedPath:cachedPath];
        }
    }
    return image;
}

-(NSImage*)cacheImageForPath:(NSURL *)path
{
    NSURL *cachedPath = [self cachedPathForURL:path];
    NSFileManager *fileManager = [OPImageCache newFileManager];

    if (![fileManager fileExistsAtPath:[cachedPath path]])
    {
        return [self resizeImageAndWriteToCache:path cachedPath:cachedPath];
    }
    return nil;
}

-(BOOL)isCachedImageAtPath:(NSURL *)path
{
    NSURL *cachedPath = [self cachedPathForURL:path];
    NSFileManager *fileManager = [OPImageCache newFileManager];
    return [fileManager fileExistsAtPath:[cachedPath path]];
}

-(void)invalidateImageForPath:(NSURL *)path
{
    NSURL *cachedPath = [self cachedPathForURL:path];
    NSFileManager *fileManager = [OPImageCache newFileManager];
    
    if (![fileManager fileExistsAtPath:[cachedPath path]])
    {
        [fileManager removeItemAtURL:cachedPath error:nil];
    }
}

-(void)clearCache
{
    NSFileManager *fileManager = [OPImageCache newFileManager];
    [fileManager removeItemAtURL:_cacheDirectory error:nil];
}

-(NSURL*)cachedImageDirectory
{
    NSFileManager *fileManager = [OPImageCache newFileManager];
    if (![fileManager fileExistsAtPath:[_cacheDirectory path]])
    {
        [fileManager createDirectoryAtURL:_cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _cacheDirectory;
}

-(NSURL*)cachedPathForURL:(NSURL*)path
{
    NSString *pathHash = [[path path] SHA256];
    return [[[self cachedImageDirectory] URLByAppendingPathComponent:pathHash] URLByAppendingPathExtension:@"jpg"];
}

-(NSImage*)resizeImageAndWriteToCache:(NSURL*)originalPath cachedPath:(NSURL*)cachedPath
{
    NSImage *image = [self scale:originalPath];
    
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    
    [imageData writeToURL:cachedPath atomically:YES];
    
    return image;
}

-(void)addToCache:(NSURL*)originalPath cachedPath:(NSURL*)cachedPath
{
    NSFileManager *fileManager = [OPImageCache newFileManager];
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:[cachedPath path] error: NULL];
    NSUInteger fileSize = [attrs fileSize];
    [_cache setObject:cachedPath forKey:originalPath cost:fileSize];
}

-(NSImage*)scale:(NSURL*)originalPath
{
    NSSize size = kOPImageCacheThumbSize;
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)originalPath, NULL);
    NSImage *image;
    
    if (imageSource != nil)
    {
        NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue,
                                          kCGImageSourceCreateThumbnailWithTransform, kCFBooleanTrue,
                                          kCGImageSourceCreateThumbnailFromImageAlways, [NSNumber numberWithFloat:size.width],
                                          kCGImageSourceThumbnailMaxPixelSize, kCFBooleanFalse, kCGImageSourceShouldCache, nil];
        
        CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)thumbnailOptions);
        
        if (thumbnail != nil)
        {
            image = [[NSImage alloc] initWithCGImage:thumbnail size:NSMakeSize(CGImageGetWidth(thumbnail), CGImageGetHeight(thumbnail))];
            
            CGImageRelease(thumbnail);
        }
        else
        {
            NSLog(@"Could not generate preview thumbnail was nil %@", originalPath);
        }
    }
    else
    {
        NSLog(@"Could not generate preview img src was nil %@", originalPath);
    }
    
    if (imageSource != nil)
    {
        CFRelease(imageSource);
    }
    
    return image;
}

@end
