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
    return [NSColor controlBackgroundColor];
}

+(NSColor *)optiqueSelectionBorderColor
{
    return [NSColor colorWithCalibratedRed:0.00 green:0.58 blue:0.87 alpha:1.00];
}

+(NSColor *)optiquePhotoSliderBackgroundFullscreenColor
{
    return [NSColor blackColor];
}

+(NSColor *)optiquePhotoSliderBackgroundColor
{
    return [NSColor colorWithCalibratedRed:0.40 green:0.40 blue:0.40 alpha:1.00];
}

@end
