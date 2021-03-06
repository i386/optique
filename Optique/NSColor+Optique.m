//
//  NSColor+Optique.m
//  Optique
//
//  Created by James Dumay on 4/06/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSColor+Optique.h"
#import "NSProcessInfo+OSVersion.h"

@implementation NSColor (Optique)

+(NSColor *)optiqueBackgroundColor
{
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastYosemite] ? [NSColor clearColor] : [NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.95 alpha:1.00];
}

+(NSColor *)optiqueSelectionColor
{
    return [NSColor colorWithCalibratedRed:0.03 green:0.42 blue:1.00 alpha:1.00];
}

+(NSColor *)optiquePhotoSliderBackgroundFullscreenColor
{
    return [NSColor blackColor];
}

+(NSColor *)optiquePhotoSliderBackgroundColor
{
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastYosemite] ? [NSColor secondarySelectedControlColor] : [NSColor colorWithCalibratedRed:0.24 green:0.24 blue:0.24 alpha:1.00];
}

+(NSColor *)optiqueGridItemEmptyColor
{
    return [NSColor colorWithCalibratedRed:0.87 green:0.87 blue:0.87 alpha:1.00];
}

+(NSColor *)optiqueItemLabelTextColor
{
    return [NSColor colorWithCalibratedRed:0.10 green:0.10 blue:0.10 alpha:1.00];
}

+(NSColor *)optiqueBorderColor
{
    return [NSColor colorWithCalibratedRed:0.83 green:0.83 blue:0.83 alpha:1.00];
}

@end
