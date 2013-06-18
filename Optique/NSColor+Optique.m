//
//  NSColor+Optique.m
//  Optique
//
//  Created by James Dumay on 4/06/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSColor+Optique.h"

@implementation NSColor (Optique)

+(NSColor *)optiqueTitlebarColor
{
    return [NSColor colorWithCalibratedRed:0.01 green:0.49 blue:0.73 alpha:1.00];
}

+(NSColor *)optiqueTitlebarBorderColor
{
    return [NSColor colorWithCalibratedRed:0.04 green:0.31 blue:0.52 alpha:1.00];
}

+(NSColor *)optiqueBackgroundColor
{
    return [NSColor colorWithCalibratedRed:0.92 green:0.94 blue:0.95 alpha:1.00];
}

+(NSColor *)optiqueSelectedBackgroundColor
{
    return [NSColor colorWithCalibratedRed:0.00 green:0.58 blue:0.87 alpha:1.00];
}

+(NSColor *)optiqueDarkBackgroundColor
{
    return [NSColor colorWithCalibratedRed:0.19 green:0.28 blue:0.37 alpha:1.00];
}

+(NSColor *)optiqueTextColor
{
    return [NSColor blackColor];
}

@end
