//
//  XPMenuItem.h
//  Optique
//
//  Created by James Dumay on 6/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (^XPMenuItemActionBlock)(NSMenuItem *sender);

@interface XPMenuItem : NSMenuItem

@property (strong) NSPredicate *visibilityPredicate;
@property (readonly, strong) XPMenuItemActionBlock actionBlock;

-(id)initWithTitle:(NSString *)aString keyEquivalent:(NSString *)charCode block:(XPMenuItemActionBlock)block;

@end
