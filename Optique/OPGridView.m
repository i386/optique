//
//  OPGridView.m
//  Optique
//
//  Created by James Dumay on 14/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPGridView.h"

@implementation OPGridView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.minimumColumnSpacing = kGridViewColumnSpacing;
        self.rowSpacing = kGridViewRowSpacing;
        self.itemSize = CGSizeMake(280.0, 175.0);
    }
    return self;
}

@end
