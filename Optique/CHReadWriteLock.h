//
//  CHReadWriteLock.h
//  Optique
//
//  Created by James Dumay on 3/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <pthread.h>

/* Thanks to http://cocoaheads.byu.edu/wiki/locks */
@interface CHReadWriteLock : NSObject <NSLocking> {
	pthread_rwlock_t lock;
}

- (void) lockForWriting;
- (BOOL) tryLock;
- (BOOL) tryLockForWriting;

@end
