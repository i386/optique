//
//  NSView+OptiqueBackground.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSView+OptiqueBackground.h"

@implementation NSView (OptiqueBackground)

-(void)drawGreyGradient
{
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.76 green:0.76 blue:0.76 alpha:1.00] endingColor:[NSColor colorWithCalibratedRed:0.94 green:0.94 blue:0.94 alpha:1.00]];
    
    [gradient drawInRect:self.bounds angle:270];
}

@end
