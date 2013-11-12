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
    return [NSColor controlBackgroundColor];
}

+(NSColor *)optiqueSelectedBackgroundColor
{
    return [NSColor colorWithCalibratedRed:0.00 green:0.58 blue:0.87 alpha:1.00];
}

+(NSColor *)optiqueDarkBackgroundColor
{
    return [NSColor colorWithCalibratedRed:0.30 green:0.30 blue:0.30 alpha:1.00];
}

+(NSColor *)optiqueDarkFullscreenColor
{
    return [NSColor blackColor];
}

+(NSColor *)optiqueTextColor
{
    return [NSColor blackColor];
}

@end
