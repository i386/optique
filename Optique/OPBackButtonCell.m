//
//  OPBackButtonCell.m
//  Optique
//
//  Created by James Dumay on 16/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPBackButtonCell.h"

@implementation OPBackButtonCell

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSButton *button = (NSButton*)controlView;
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc]
                                            initWithAttributedString:button.attributedTitle];
    NSUInteger len = [attrTitle length];
    NSRange range = NSMakeRange(0, len);
    [attrTitle addAttribute:NSForegroundColorAttributeName
                      value:[NSColor whiteColor]
                      range:range];
    [attrTitle fixAttributesInRange:range];
    [self setAttributedTitle:attrTitle];
    
    NSRect imageRect = [self imageRectForBounds:cellFrame];
    
    NSRect textRect = [self titleRectForBounds:cellFrame];
    NSRect newTextRect = NSMakeRect(textRect.origin.x, textRect.origin.y - 2, textRect.size.width, textRect.size.height);
    
    if (self.isHighlighted)
    {
        NSRect srcRect = NSMakeRect(0, 0, button.image.size.width, button.image.size.height);
        [button.image drawInRect:imageRect fromRect:srcRect operation:NSCompositeDestinationOver fraction:0.8f];
    }
    else
    {
        [[button image] drawInRect:imageRect];
    }
    
    [[button attributedTitle] drawInRect:newTextRect];
}

@end
