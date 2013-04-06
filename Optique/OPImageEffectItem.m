//
//  OPImageEffectItem.m
//  Optique
//
//  Created by James Dumay on 6/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImageEffectItem.h"
#import "OPImageEffectItemView.h"

@interface OPImageEffectItem ()

@end

@implementation OPImageEffectItem

- (void)setSelected:(BOOL)flag
{
    [super setSelected:flag];
    
    OPImageEffectItemView *view = (OPImageEffectItemView*)self.view;
    [view setSelected:flag];
    [view setNeedsDisplay:YES];
}

@end
