//
//  OPWindowContentView.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPWindowContentView.h"
#import "NSView+OptiqueBackground.h"

@implementation OPWindowContentView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layerUsesCoreImageFilters = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawBackground];
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

@end
