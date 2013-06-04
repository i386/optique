//
//  NSColor+Optique.m
//  Optique
//
//  Created by James Dumay on 4/06/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSColor+Optique.h"

@implementation NSColor (Optique)

+(NSColor *)optiqueBackgroundColor
{
    return [NSColor controlHighlightColor];
}

+(NSColor *)optiqueDarkBackgroundColor
{
    return [NSColor colorWithCalibratedRed:0.17 green:0.17 blue:0.17 alpha:1.00];
}

@end
