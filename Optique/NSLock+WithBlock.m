//
//  NSLock+DoWithLock.m
//  Optique
//
//  Created by James Dumay on 30/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSLock+WithBlock.h"

@implementation NSLock (WithBlock)

-(id)withBlock:(OPLockBlock)block
{
    [self lock];
    @try
    {
        return block();
    }
    @finally
    {
        [self unlock];
    }
}

@end
