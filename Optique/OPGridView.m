//
//  OPGridView.m
//  Optique
//
//  Created by James Dumay on 14/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPGridView.h"

@implementation OPGridView

#define kGridViewRowSpacing 30.f
#define kGridViewColumnSpacing 10.f

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.minimumColumnSpacing = kGridViewColumnSpacing;
        self.rowSpacing = kGridViewRowSpacing;
        self.itemSize = CGSizeMake(260.0, 175.0);
    }
    return self;
}

@end
