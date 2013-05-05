//
//  NSObject+PerformBlock.m
//  Optique
//
//  Created by James Dumay on 9/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSObject+PerformBlock.h"

@implementation NSObject (PerformBlock)

-(void)performBlockOnMainThread:(void (^)(void))block
{
    [self performBlockOnMainThread:block waitUntilDone:NO];
}

-(void)performBlockOnMainThreadAndWaitUntilDone:(void (^)(void))block
{
    [self performBlockOnMainThread:block waitUntilDone:YES];
}

-(void)performBlockOnMainThread:(void (^)(void))block waitUntilDone:(BOOL)wait
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        if (wait)
        {
            dispatch_sync(dispatch_get_main_queue(), block);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), block);
        }
    }
}

-(void)performBlockInBackground:(void (^)(void))block
{
    [self performSelectorInBackground:@selector(_performBlock:) withObject:block];
}

-(void)_performBlock:(void (^)(void))block
{
    block();
}

@end
