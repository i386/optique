//
//  OPGridView.m
//  Optique
//
//  Created by James Dumay on 2/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoGridView.h"
#import "NSView+OptiqueBackground.h"

NSString *const OPPhotoGridViewReuseIdentifier = @"OPPhotoGridViewReuseIdentifier";

@implementation OPPhotoGridView

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawBackground];
}

@end
