//
//  OPNavigationBarButtonCell.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationBarButtonCell.h"

/** http://www.amateurinmotion.com/articles/2010/05/06/drawing-custom-nsbutton-in-cocoa.html **/

@implementation OPNavigationBarButtonCell

- (void)drawBezelWithFrame:(NSRect)frame
                    inView:(NSView *)controlView
{
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
    
    CGFloat roundedRadius = 4.0f;
    
    // Outer stroke (drawn as gradient)
    
    [ctx saveGraphicsState];
    NSBezierPath *outerClip = [NSBezierPath bezierPathWithRoundedRect:frame
                                                              xRadius:roundedRadius
                                                              yRadius:roundedRadius];
    [outerClip setClip];
    
    NSGradient *outerGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                 [NSColor colorWithDeviceWhite:0.20f alpha:1.0f], 0.0f,
                                 [NSColor colorWithDeviceWhite:0.21f alpha:1.0f], 1.0f,
                                 nil];
    
    [outerGradient drawInRect:[outerClip bounds] angle:90.0f];

    [ctx restoreGraphicsState];
    
    // Background gradient
    
    [ctx saveGraphicsState];
    NSBezierPath *backgroundPath =
    [NSBezierPath bezierPathWithRoundedRect:frame
                                    xRadius:roundedRadius
                                    yRadius:roundedRadius];
    [backgroundPath setClip];
    
    [NSColor colorWithPatternImage:[NSImage imageNamed:@"buttonbg"]];
    
    
    NSImage *bgImage = [NSImage imageNamed:@"buttonbg"];
    
    if (!self.isHighlighted)
    {
        [bgImage drawInRect:frame fromRect:NSMakeRect(0.0f, 0.0f, bgImage.size.width, bgImage.size.height) operation:NSCompositeSourceOver fraction:1.0];
    }
    else
    {
        [bgImage drawInRect:frame fromRect:NSMakeRect(0.0f, 0.0f, bgImage.size.width, bgImage.size.height) operation:NSCompositeSourceOver fraction:0.7];
    }
    
    [ctx restoreGraphicsState];
}

@end
