//
//  OPAsyncOperation.m
//  Optique
//
//  Created by James Dumay on 1/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFuture.h"

@interface OPFuture() {
    dispatch_semaphore_t _semaphore;
    id _obj;
}

@end

@implementation OPFuture

-(id)init
{
    self = [super init];
    if (self)
    {
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

-(void)signal:(id)obj
{
    _obj = obj;
    dispatch_semaphore_signal(_semaphore);
}

-(id)wait
{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    _semaphore = NULL;
    return _obj;
}

@end
