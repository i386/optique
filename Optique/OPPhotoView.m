//
//  OPPhotoView.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoView.h"
#import "NSView+OptiqueBackground.h"

@implementation OPPhotoView

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawGreyGradient];
}

@end
