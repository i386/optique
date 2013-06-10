//
//  XPSharingService.h
//  Optique
//
//  Created by James Dumay on 23/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XPSharingService <NSObject>

/**
 NSMenuItems that link to the sharing action
 */
-(NSMutableArray*)sharingMenuItems;

@end
