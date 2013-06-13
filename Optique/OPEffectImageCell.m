//
//  OPImageCell.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPEffectImageCell.h"
#import "NSColor+Optique.h"

@implementation OPEffectImageCell

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
    CALayer *layer = controlView.layer;
    layer.borderWidth = 1;
    layer.borderColor = [NSColor optiqueTitlebarBorderColor].CGColor;
    
    [super drawWithFrame:cellFrame inView:controlView];
}

-(void)finalize
{
    CALayer *layer = self.controlView.layer;
    if (layer.shadowPath)
    {
        CGPathRelease(self.controlView.layer.shadowPath);
    }
    
    if (layer.shadowColor)
    {
        CGColorRelease(self.controlView.layer.shadowColor);
    }
}

@end
