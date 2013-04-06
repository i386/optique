//
//  OPImageEffectItem.m
//  Optique
//
//  Created by James Dumay on 6/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImageEffectItemView.h"

@implementation OPImageEffectItemView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (_selected)
    {
        [[NSColor whiteColor] set];
        NSRectFill([self bounds]);
    }
}

@end
