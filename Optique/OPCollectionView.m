//
//  OPCollectionView.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCollectionView.h"
#import "NSView+OptiqueBackground.h"

@implementation OPCollectionView

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawBackground];
}

@end