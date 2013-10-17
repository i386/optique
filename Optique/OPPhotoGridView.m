//
//  OPPhotoGridView.m
//  Optique
//
//  Created by James Dumay on 17/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoGridView.h"

@implementation OPPhotoGridView

#define kGridViewRowSpacing 20.0f
#define kGridViewColumnSpacing 20.0f

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
