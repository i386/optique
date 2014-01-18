//
//  OPImagePreviewService.m
//  Optique
//
//  Created by James Dumay on 3/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPItemPreviewService.h"
#import "OPImageCache.h"
#import "OPLocalItem.h"

#define fOPImagePreviewServiceLargeSize 25165824

@interface OPItemPreviewService() {
    NSMapTable *_locks;
    NSOperationQueue *_smallImageQueue;
    NSOperationQueue *_largeImageQueue;
}

@end

@implementation OPItemPreviewService

static OPItemPreviewService *_defaultService;

+(OPItemPreviewService *)defaultService
{
    if (!_defaultService)
    {
        _defaultService = [[OPItemPreviewService alloc] init];
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

-(NSImage *)previewImage:(id<XPItem>)item loaded:(XPImageCompletionBlock)completionBlock
{
    if ([item type] != XPItemTypePhoto)
    {
        NSLog(@"Cannot previewImageWithItem:loaded: as type is unsupported");
        return nil;
    }
    
    NSImage __block *image;
    if ([((id)item) respondsToSelector:@selector(thumbnail)])
    {
        image = item.thumbnail;
    }
    else if ([((id)item) respondsToSelector:@selector(url)])
    {
        image = [self previewImageAtURL:item.url loaded:completionBlock];
    }
    else
    {
        NSLog(@"Cannot previewImageWithItem:loaded: for %@", [item class]);
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
