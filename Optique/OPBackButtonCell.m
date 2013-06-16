//
//  OPBackButtonCell.m
//  Optique
//
//  Created by James Dumay on 16/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPBackButtonCell.h"

@implementation OPBackButtonCell

-(NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc]
                                            initWithAttributedString:title];
    NSUInteger len = [attrTitle length];
    NSRange range = NSMakeRange(0, len);
    [attrTitle addAttribute:NSForegroundColorAttributeName
                      value:[NSColor whiteColor]
                      range:range];
    [attrTitle fixAttributesInRange:range];
    [self setAttributedTitle:attrTitle];
    
    NSRect newFrame = NSMakeRect(frame.origin.x, frame.origin.y - 2, frame.size.width, frame.size.height);
    return [super drawTitle:attrTitle withFrame:newFrame inView:controlView];
}

@end
