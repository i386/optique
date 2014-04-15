//
//  OPRotateOperationOptimizer.m
//  Optique
//
//  Created by James Dumay on 13/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPRotateOperationOptimizer.h"
#import "OPRotateEditOperation.h"
#import <math.h>

@implementation OPRotateOperationOptimizer

-(NSArray *)optimize:(NSArray *)operations
{
    NSArray *rotateOperations = [operations bk_select:^BOOL(id obj) {
        return [obj isKindOfClass:[OPRotateEditOperation class]];
    }];
    
    NSArray *allNonRotateOps = [operations bk_select:^BOOL(id obj) {
        return ![obj isKindOfClass:[OPRotateEditOperation class]];
    }];
    
    if (rotateOperations.count > 4)
    {
        NSMutableArray *newOperations = [NSMutableArray arrayWithArray:rotateOperations];
        while (newOperations.count > 4)
        {
            [newOperations removeObjectAtIndex:0];
        }
        
        return [[rotateOperations arrayByAddingObjectsFromArray:newOperations] arrayByAddingObjectsFromArray:allNonRotateOps];
    }
    else
    {
        return operations;
    }
}

@end
