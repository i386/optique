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
    layer.shadowOpacity = 0.3;
    layer.shadowColor = [[NSColor blackColor] CGColor];
    layer.shadowOffset = NSMakeSize(3, -3);
    layer.shadowRadius = 2;
    layer.shadowPath = CGPathCreateWithRect(cellFrame, NULL);
    
    [super drawWithFrame:cellFrame inView:controlView];
}

@end
