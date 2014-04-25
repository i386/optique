//
//  OPLineBox.m
//  Optique
//
//  Created by James Dumay on 25/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPLineBox.h"
#import "NSColor+Optique.h"

@implementation OPLineBox

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [_color set];
    NSRectFill(dirtyRect);
}

-(void)setColor:(NSColor *)color
{
    self.borderColor = color;
    _color = color;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.borderWidth = 1.5;
    self.boxType = NSBoxCustom;
    self.color = [NSColor optiqueBorderColor];
}

@end
