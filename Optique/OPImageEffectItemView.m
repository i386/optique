//
//  OPImageEffectItem.m
//  Optique
//
//  Created by James Dumay on 6/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImageEffectItemView.h"
#import "NSView+OptiqueBackground.h"

@implementation OPImageEffectItemView

- (void)drawRect:(NSRect)dirtyRect
{
    if (_selected)
    {
        [self drawEffectsViewBackgroundSelected];
    }
    else
    {
        [self drawTransparentBackground];
    }
}

@end
