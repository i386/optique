//
//  ;
//  Optique
//
//  Created by James Dumay on 1/11/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPNotificationSynchronizer : NSObject

+(OPNotificationSynchronizer*)watchForIncrementNotification:(NSString*)incrementNotificationName
                                   deincrementNotification:(NSString *)deincrementNotificationName
                                             incrementBlock:(XPBlock)incrementBlock
                                          deincrementBlock:(XPBlock)deincrementBlock;

-(BOOL)isSynchronized;

@end
