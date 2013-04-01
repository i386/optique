//
//  OPImageCache.m
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImageCache.h"
#import "NSImage+MGCropExtensions.h"
#import <NSHash/NSString+NSHash.h>

#define THUMB_SIZE NSMakeSize(260, 175)

@implementation OPImageCache

static OPImageCache *_sharedPreviewCache;

+(OPImageCache *)sharedPreviewCache
{
    if (!_sharedPreviewCache)
    {
        _sharedPreviewCache = [[OPImageCache alloc] initWithIdentity:@"previews" size:THUMB_SIZE];
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
    
    NSFileManager *fileManager = [OPImageCache newFileManager];
    
    NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    _cacheDirectory = [[[[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"com.whimsy.optique" isDirectory:YES] URLByAppendingPathComponent:identity isDirectory:YES];
    
    [fileManager createDirectoryAtURL:_cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    return self;
}

-(NSImage *)loadImageForPath:(NSURL *)path
{
    NSURL *cachedPath = [self cachedPathForURL:path];
    NSFileManager *fileManager = [OPImageCache newFileManager];
    
    NSImage *image;
    
    NSString *stringPath = [cachedPath path];
    
    //Check if image is on file system
    if ([fileManager fileExistsAtPath:stringPath])
    {
        image = [[NSImage alloc] initByReferencingURL:cachedPath];
    }
    
    //If it isn't on the filesystem cache, generate a new cached image
    if (!image)
    {
//        [self resizeImageAndWriteToCache:path cachedPath:cachedPath];
    }
    
    return image;
}

-(void)cacheImageForPath:(NSURL *)path
{
    NSURL *cachedPath = [self cachedPathForURL:path];
    NSFileManager *fileManager = [OPImageCache newFileManager];

    if (![fileManager fileExistsAtPath:[cachedPath path]])
    {
        [self resizeImageAndWriteToCache:path cachedPath:cachedPath];
    }
}

-(NSURL*)cachedPathForURL:(NSURL*)path
{
    NSString *pathHash = [[path path] SHA256];
    return [[_cacheDirectory URLByAppendingPathComponent:pathHash] URLByAppendingPathExtension:@"tiff"];
}

-(void)resizeImageAndWriteToCache:(NSURL*)originalPath cachedPath:(NSURL*)cachedPath
{
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:originalPath];
    image = [image imageCroppedToFitSize:THUMB_SIZE];
    [[image TIFFRepresentation] writeToURL:cachedPath atomically:YES];
}

@end
