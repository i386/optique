//
//  NSLock+DoWithLock.h
//  Optique
//
//  Created by James Dumay on 30/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^OPLockBlock)();

@interface NSLock (DoWithLock)

-(id)withBlock:(OPLockBlock)block;

@end
