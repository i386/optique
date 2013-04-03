//
//  OPImagePreviewService.m
//  Optique
//
//  Created by James Dumay on 3/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImagePreviewService.h"
#import "OPImageCache.h"

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
    }
    return self;
}

-(NSImage *)previewImageAtURL:(NSURL *)url loaded:(void (^)(NSImage *))loadBlock
{
    OPImageCache *cache = [OPImageCache sharedPreviewCache];
    
    if ([cache isCachedImageAtPath:url])
    {
        return [cache loadImageForPath:url];
    }
    else
    {
        [_queue addOperationWithBlock:^
        {
            NSImage *image = [cache loadImageForPath:url];
            loadBlock(image);
        }];
        return [NSImage imageNamed:@"loading-preview"];
    }
}

@end
