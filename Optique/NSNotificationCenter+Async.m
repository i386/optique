//
//  NSNotificationCenter+Async.m
//  Optique
//
//  Created by James Dumay on 5/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSNotificationCenter+Async.h"
#import "NSObject+PerformBlock.h"

@implementation NSNotificationCenter (Async)

-(void)postAsyncNotification:(NSNotification *)notification
{
    [self performBlockInBackground:^{
        [self postNotification:notification];
    }];
}

-(void)postAsyncNotificationName:(NSString *)aName object:(id)anObject
{
    [self performBlockInBackground:^{
        [self postNotificationName:aName object:anObject];
    }];
}

-(void)postAsyncNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    [self performBlockInBackground:^{
        [self postNotificationName:aName object:anObject userInfo:aUserInfo];
    }];
}

@end
