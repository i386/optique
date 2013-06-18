//
//  OPSegmentedControl.m
//  Optique
//
//  Created by James Dumay on 18/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPSegmentedControl.h"
#import "NSColor+Optique.h"

@implementation OPSegmentedControl

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.cell setControlTint:NSClearControlTint ];
    }
    
    return self;
}

@end
