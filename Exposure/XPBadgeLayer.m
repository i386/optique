//
//  XPBadgeLayer.m
//  Optique
//
//  Created by James Dumay on 8/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "XPBadgeLayer.h"

@implementation XPBadgeLayer

-(CALayer *)hitTest:(CGPoint)p
{
    return [self.superlayer hitTest:p];
}

@end
