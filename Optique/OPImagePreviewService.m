//
//  OPImagePreviewService.m
//  Optique
//
//  Created by James Dumay on 3/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImagePreviewService.h"
#import "OPImageCache.h"
#import "OPLocalPhoto.h"

#define fOPImagePreviewServiceLargeSize 25165824

@interface OPImagePreviewService() {
    NSMapTable *_locks;
    NSOperationQueue *_smallImageQueue;
    NSOperationQueue *_largeImageQueue;
}

@end

@implementation OPImagePreviewService

static OPImagePreviewService *_defaultService;

+(OPImagePreviewService *)defaultService
{
    if (!_defaultService)
    {
        _defaultService = [[OPImagePreviewService alloc] init];
    }
    return _defaultService;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        _smallImageQueue = [[NSOperationQueue alloc] init];
        [_smallImageQueue setMaxConcurrentOperationCount:10];
        
        _largeImageQueue = [[NSOperationQueue alloc] init];
        [_largeImageQueue setMaxConcurrentOperationCount:1];
        
        _locks = [NSMapTable weakToWeakObjectsMapTable];
    }
    return self;
}

-(NSImage *)previewImageWithPhoto:(id<XPPhoto>)photo loaded:(XPImageCompletionBlock)completionBlock
{
    NSImage __block *image;
    if ([((id)photo) respondsToSelector:@selector(thumbnail)])
    {
        image = photo.thumbnail;
    }
    else if ([((id)photo) respondsToSelector:@selector(url)])
    {
        image = [self previewImageAtURL:photo.url loaded:completionBlock];
    }
    return image;
}

-(NSImage *)previewImageAtURL:(NSURL *)url loaded:(XPImageCompletionBlock)completionBlock
{
    OPImageCache *cache = [OPImageCache sharedPreviewCache];
    
    if (![cache isCachedImageAtPath:url])
    {
        //Only synchronizes if the image does not exist
        volatile NSLock *lock = [self acquireLockForURL:url];
        
        @try
        {
            //If the lock has not been acquired then lock and queue thumb operation
            if (![lock tryLock])
            {
                unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:nil] fileSize];
                
                if (fileSize >= fOPImagePreviewServiceLargeSize)
                {
                    [_largeImageQueue addOperationWithBlock:^
                     {
                         NSImage *image = [cache loadImageForPath:url];
                         completionBlock(image);
                     }];
                }
                else
                {
                    [_smallImageQueue addOperationWithBlock:^
                     {
                         NSImage *image = [cache loadImageForPath:url];
                         completionBlock(image);
                     }];
                }
                
                
                //Remove the lock
                [_locks removeObjectForKey:url];
            }
        }
        @finally
        {
            [lock unlock];
        }
        return nil;
    }
    
    return [cache loadImageForPath:url];
}

/** calling this method will sync on this instance **/
-(volatile NSLock*)acquireLockForURL:(NSURL*)url
{
    @synchronized(self)
    {
        volatile NSLock *lock = [_locks objectForKey:url];
        if (!lock)
        {
            [_locks setObject:[[NSLock alloc] init] forKey:url];
        }
        return lock;
    }
}

@end
