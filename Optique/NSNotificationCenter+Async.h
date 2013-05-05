//
//  NSNotificationCenter+Async.h
//  Optique
//
//  Created by James Dumay on 5/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (Async)

-(void)postAsyncNotification:(NSNotification *)notification;

-(void)postAsyncNotificationName:(NSString *)aName object:(id)anObject;

-(void)postAsyncNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
