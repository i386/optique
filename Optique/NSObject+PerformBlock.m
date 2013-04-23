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
    [self performSelectorOnMainThread:@selector(_performBlock:) withObject:block waitUntilDone:NO];
}

-(void)performBlockOnMainThreadAndWaitUntilDone:(void (^)(void))block
{
    [self performSelectorOnMainThread:@selector(_performBlock:) withObject:block waitUntilDone:YES];
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
