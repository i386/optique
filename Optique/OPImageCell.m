//
//  OPImageCell.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImageCell.h"

@implementation OPImageCell

-(id)initImageCell:(NSImage *)image
{
    self = [super initImageCell:image];
    if (self)
    {
        [self.controlView setWantsLayer:YES];
    }
    return self;
}

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    CGColorRef color = [[NSColor whiteColor] CGColor];
    CALayer *layer = controlView.layer;
    layer.borderColor = color;
    layer.borderWidth = 10;
    layer.backgroundColor = color;
    layer.shadowColor = [[NSColor blackColor] CGColor];
    layer.shadowOffset = NSMakeSize(10, 10);
    layer.shadowRadius = 2;
    
//    NSBezierPath *path = [NSBezierPath bezierPathWithRect:cellFrame];
//    layer.shadowPath = path.CGPath;
    
    [super drawWithFrame:cellFrame inView:controlView];
}

@end
