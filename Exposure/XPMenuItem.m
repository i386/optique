//
//  XPMenuItem.m
//  Optique
//
//  Created by James Dumay on 6/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "XPMenuItem.h"

@implementation XPMenuItem

-(id)initWithTitle:(NSString *)aString keyEquivalent:(NSString *)charCode block:(XPMenuItemActionBlock)block
{
    self = [super initWithTitle:aString action:@selector(_performActionBlock:) keyEquivalent:charCode];
    if (self)
    {
        _actionBlock = block;
        self.target = self;
    }
    return self;
}

-(void)_performActionBlock:(XPMenuItem*)sender
{
    _actionBlock(sender);
}

@end
