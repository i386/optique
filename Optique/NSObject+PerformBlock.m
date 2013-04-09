//
//  NSObject+PerformBlock.m
//  Optique
//
//  Created by James Dumay on 9/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSObject+PerformBlock.h"

@implementation NSObject (PerformBlock)

-(void)performOnMainThreadWithBlock:(void (^)(void))block
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:block];
}

@end
