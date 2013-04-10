//
//  OPImagePreviewService.m
//  Optique
//
//  Created by James Dumay on 3/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImagePreviewService.h"
#import "OPImageCache.h"

@interface OPImagePreviewService() {
    NSMapTable *_locks;
    NSOperationQueue *_queue;
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
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:10];
        _locks = [NSMapTable weakToWeakObjectsMapTable];
    }
    return self;
}

-(NSImage *)previewImageAtURL:(NSURL *)url loaded:(void (^)(NSImage *))loadBlock
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
                [_queue addOperationWithBlock:^
                 {
                     NSImage *image = [cache loadImageForPath:url];
                     loadBlock(image);
                 }];
                
                //Remove the lock
                [_locks removeObjectForKey:url];
            }
        }
        @finally
        {
            [lock unlock];
        }
        return [NSImage imageNamed:@"loading-preview"];
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
