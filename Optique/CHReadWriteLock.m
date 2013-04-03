//
//  CHReadWriteLock.m
//  Optique
//
//  Created by James Dumay on 3/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "CHReadWriteLock.h"

@implementation CHReadWriteLock

- (id) init {
	if (self = [super init]) {
		pthread_rwlock_init(&lock, NULL);
	}
	return self;
}

- (void) dealloc {
	pthread_rwlock_destroy(&lock);
}

- (void) finalize {
	pthread_rwlock_destroy(&lock);
	[super finalize];
}

- (void) lock {
	pthread_rwlock_rdlock(&lock);
}

- (void) unlock {
	pthread_rwlock_unlock(&lock);
}

- (void) lockForWriting {
	pthread_rwlock_wrlock(&lock);
}

- (BOOL) tryLock {
	return (pthread_rwlock_tryrdlock(&lock) == 0);
}

- (BOOL) tryLockForWriting {
	return (pthread_rwlock_trywrlock(&lock) == 0);
}

@end