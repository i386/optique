//
//  OPItemPreviewManager.m
//  Optique
//
//  Created by James Dumay on 19/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPItemPreviewManager.h"
#import <AVFoundation/AVFoundation.h>
#import <NSHash/NSString+NSHash.h>
#import "NSLock+WithBlock.h"

#define fOPImagePreviewServiceLargeSize 25165824
#define CACHE_SIZE              524288000
#define kOPImageCacheThumbSize  NSMakeSize(310, 225)

typedef NSImage* (^XPImageExtraction)(id<XPItem>, NSSize);

static XPImageExtraction IMAGE_PREVIEW_EXTRACTOR = ^NSImage* (id<XPItem>item, NSSize size) {
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[item url], NULL);
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
            NSLog(@"Could not generate preview thumbnail was nil %@", [item url]);
        }
    }
    else
    {
        NSLog(@"Could not generate preview img src was nil %@", [item url]);
    }
    
    if (imageSource != nil)
    {
        CFRelease(imageSource);
    }
    
    return image;
};

static XPImageExtraction VIDEO_PREVIEW_EXTRACTOR = ^NSImage* (id<XPItem>item, NSSize size) {
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:item.url options:nil];
    AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil];
    
    if (imageRef != NULL)
    {
        CGFloat height = CGImageGetHeight(imageRef);
        CGFloat width = CGImageGetWidth(imageRef);
        NSSize size = NSMakeSize(width, height);
        
        return [[NSImage alloc] initWithCGImage:imageRef size:size];
    }
    return nil;
};

@interface OPItemPreviewManager() <NSCacheDelegate>

@property (strong) NSCache *cache;
@property (strong) NSURL *cacheDirectory;
@property (strong) NSOperationQueue *smallImageQueue;
@property (strong) NSOperationQueue *largeImageQueue;
@property (strong) NSMapTable *locks;

@end

@implementation OPItemPreviewManager

static OPItemPreviewManager *_defaultManager;

+ (OPItemPreviewManager *)defaultManager
{
    if (!_defaultManager)
    {
        _defaultManager = [[OPItemPreviewManager alloc] init];
    }
    return _defaultManager;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        _cache = [[NSCache alloc] init];
        _cache.delegate = self;
        _cache.countLimit = CACHE_SIZE;
        
        _smallImageQueue = [[NSOperationQueue alloc] init];
        [_smallImageQueue setMaxConcurrentOperationCount:10];
        
        _largeImageQueue = [[NSOperationQueue alloc] init];
        [_largeImageQueue setMaxConcurrentOperationCount:1];
        
        _locks = [NSMapTable weakToWeakObjectsMapTable];
        
        NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
        _cacheDirectory = [[[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"com.whimsy.optique" isDirectory:YES] URLByAppendingPathComponent:@"previews" isDirectory:YES];
    }
    return self;
}

-(void)previewItem:(id<XPItem>)item size:(NSSize)size loaded:(XPImageCompletionBlock)completionBlock
{
    if (!item) return;
    
    //If there is a thumbnail
    if ([item respondsToSelector:@selector(thumbnail)])
    {
        completionBlock(item.thumbnail);
        return;
    }
    
    volatile NSLock *lock = [self lockForItem:item];
    
    [lock withBlock:^id{
        
        NSImage *image = [self lookupInCache:item size:size];
        if (!image)
        {
            XPImageExtraction extractor;
            
            switch ([item type]) {
                case XPItemTypePhoto:
                    extractor = IMAGE_PREVIEW_EXTRACTOR;
                    break;
                    
                case XPItemTypeVideo:
                    extractor = VIDEO_PREVIEW_EXTRACTOR;
                    break;
                    
                default:
                    break;
            }
            
            if (extractor)
            {
                if ([self isLargeItem:item])
                {
                    [_largeImageQueue addOperationWithBlock:^
                     {
                         NSImage * image = extractor(item, size);
                         if (image)
                         {
                             [self writeToCache:image item:item size:size];
                             completionBlock(image);
                         }
                     }];
                }
                else
                {
                    [_smallImageQueue addOperationWithBlock:^
                     {
                         NSImage * image = extractor(item, size);
                         if (image)
                         {
                             [self writeToCache:image item:item size:size];
                             completionBlock(image);
                         }
                     }];
                }
            }
        }
        completionBlock(image);
        return image;
    }];
}

-(void)clearCache
{
    [_cache removeAllObjects];
    [[NSFileManager defaultManager] removeItemAtURL:_cacheDirectory error:nil];
}

-(NSImage*)lookupInCache:(id<XPItem>)item size:(NSSize)size
{
    if (item.url)
    {
        NSURL *url = [self cachedPathForURL:[item url] size:size];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:url.path])
        {
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
            [image setCacheMode:NSImageCacheNever];
            return image;
        }
    }
    return nil;
}

-(void)writeToCache:(NSImage*)image item:(id<XPItem>)item size:(NSSize)size
{
    //Write image
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    
    NSURL *url = [self cachedPathForURL:[item url] size:size];
    [imageData writeToURL:url atomically:YES];
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error: NULL];
    NSUInteger fileSize = [attrs fileSize];
    
    //Add to cache
    [_cache setObject:url forKey:[item url] cost:fileSize];
}

-(void)addToCache:(NSURL*)originalPath cachedPath:(NSURL*)cachedPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:[cachedPath path] error: NULL];
    NSUInteger fileSize = [attrs fileSize];
    [_cache setObject:cachedPath forKey:originalPath cost:fileSize];
}

-(BOOL)isLargeItem:(id<XPItem>)item
{
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[[item url] path] error:nil] fileSize];
    
    return fileSize >= fOPImagePreviewServiceLargeSize;
}

-(NSURL*)cachedPathForURL:(NSURL*)path size:(NSSize)size
{
    NSString *sizeComponent = [NSString stringWithFormat:@"_%fx%f", size.width, size.height];
    NSString *pathHash = [[path path] SHA256];
    NSString *fileName = [pathHash stringByAppendingString:sizeComponent];
    return [[[self cachedImageDirectory] URLByAppendingPathComponent:fileName] URLByAppendingPathExtension:@"tiff"];
}

-(NSURL*)cachedImageDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[_cacheDirectory path]])
    {
        [fileManager createDirectoryAtURL:_cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _cacheDirectory;
}

-(volatile NSLock*)lockForItem:(id<XPItem>)photo
{
    @synchronized(self)
    {
        volatile NSLock *lock = [_locks objectForKey:photo];
        if (!lock)
        {
            lock = [[NSLock alloc] init];
            [_locks setObject:lock forKey:photo];
        }
        return lock;
    }
}

-(void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    NSURL *url = (NSURL*)obj;
    if (![[NSFileManager defaultManager] removeItemAtURL:url error:nil])
    {
        NSLog(@"Unable to evict from preview image cache %@", url);
    }
}

@end
