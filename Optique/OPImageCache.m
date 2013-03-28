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

-(id)initWithIdentity:(NSString *)identity size:(NSSize)size
{
    self = [super init];
    _size = size;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    _cacheDirectory = [[[[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"com.whimsy.optique" isDirectory:YES] URLByAppendingPathComponent:identity isDirectory:YES];
    
    [fileManager createDirectoryAtURL:_cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    return self;
}

-(NSImage *)loadImageForPath:(NSURL *)path
{
    NSString *pathHash = [[path path] SHA256];
    
    //Check if the image does not exist check in the file system cache location
    NSURL *cachedPath = [_cacheDirectory URLByAppendingPathComponent:pathHash];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSImage *image;
    if ([fileManager fileExistsAtPath:[cachedPath path]])
    {
        image = [[NSImage alloc] initByReferencingURL:cachedPath];
    }
    
    //If it isn't on the filesystem cache, load the image
    if (!image)
    {
        image = [[NSImage alloc] initWithContentsOfURL:path];
        image = [image imageToFitSize:_size method:MGImageResizeScale];
        [self writeToCache:image pathHash:pathHash];
    }
    
    return image;
}

-(void)writeToCache:(NSImage*)image pathHash:(NSString*)pathHash
{
    NSURL *url = [_cacheDirectory URLByAppendingPathComponent:pathHash];
    
    [image lockFocus];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, image.size.width, image.size.height)];
    [image unlockFocus];
    
    [[bitmapRep representationUsingType:NSTIFFFileType properties:Nil] writeToURL:url atomically:YES];
}

@end
