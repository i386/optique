//
//  NSObject+PerformBlock.h
//  Optique
//
//  Created by James Dumay on 9/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PerformBlock)

-(void)performBlockOnMainThread:(void (^)(void))block;

-(void)performBlockOnMainThreadAndWaitUntilDone:(void (^)(void))block;

-(void)performBlockInBackground:(void (^)(void))block;

@end
