//
//  OPNotificationSynchronizer.m
//  Optique
//
//  Created by James Dumay on 1/11/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNotificationSynchronizer.h"
#import "NSLock+WithBlock.h"

@interface OPNotificationSynchronizer()

@property (strong) NSLock *lock;
@property (nonatomic, copy) XPBlock incrementBlock;
@property (nonatomic, copy) XPBlock deincrementBlock;
@property (strong) NSString *incrementNotificationName;
@property (strong) NSString *deincrementNotificationName;
@property (assign) NSUInteger count;

@end

@implementation OPNotificationSynchronizer

+(instancetype)watchForIncrementNotification:(NSString *)incrementNotificationName
                                     deincrementNotification:(NSString *)deincrementNotificationName
                                              incrementBlock:(XPBlock)incrementBlock
                                            deincrementBlock:(XPBlock)deincrementBlock
{
    OPNotificationSynchronizer *instance = [[OPNotificationSynchronizer alloc] init];
    
    instance.lock = [[NSLock alloc] init];
    instance.incrementBlock = incrementBlock;
    instance.deincrementBlock = deincrementBlock;
    instance.incrementNotificationName = incrementNotificationName;
    instance.deincrementNotificationName = deincrementNotificationName;
    
    [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(add:) name:incrementNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(remove:) name:deincrementNotificationName object:nil];
    
    return instance;
}

-(BOOL)isSynchronized
{
    NSNumber *number = [_lock withBlock:^id{
        return [NSNumber numberWithBool:_count == 0];
    }];
    return number.boolValue;
}

-(void)add:(NSNotification*)notification
{
    [_lock withBlock:^id{
        NSUInteger oldCount = _count;
        _count++;
        if (_incrementBlock)
        {
            if (oldCount == 0)
            {
                _incrementBlock();
            }
        }
        else
        {
            NSLog(@"Error: incrementBlock of OPNotificationSynchronizer is nil");
        }
        return nil;
    }];
}

-(void)remove:(NSNotification*)notification
{
    [_lock withBlock:^id{
        _count--;
        if (_count == 0)
        {
            if (_deincrementBlock)
            {
                _deincrementBlock();
            }
            else
            {
                NSLog(@"Error: deincrementBlock of OPNotificationSynchronizer is nil");
            }
        }
        return nil;
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_incrementNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_deincrementNotificationName object:nil];
}

@end
