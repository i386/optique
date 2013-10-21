//
//  OPPhotoGridView.m
//  Optique
//
//  Created by James Dumay on 17/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoGridView.h"

@implementation OPPhotoGridView

#define kGridViewRowSpacing 20.0f
#define kGridViewColumnSpacing 20.0f

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.minimumColumnSpacing = kGridViewColumnSpacing;
        self.rowSpacing = kGridViewRowSpacing;
        self.itemSize = CGSizeMake(280.0, 175.0);
        self.isSelectionSticky = NO;
    }
    return self;
}

-(void)mouseDown:(NSEvent *)theEvent
{
    if (_isSelectionSticky)
    {
        NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSUInteger index = [self indexForCellAtPoint:pointInView];
        
        NSUInteger modifierFlags = [[NSApp currentEvent] modifierFlags];
        BOOL commandKeyDown      = ((modifierFlags & NSCommandKeyMask) == NSCommandKeyMask);
        BOOL shiftKeyDown        = ((modifierFlags & NSShiftKeyMask) == NSShiftKeyMask);
        BOOL invertSelection     = commandKeyDown || shiftKeyDown;
        BOOL isSelected          = [[self selectionIndexes] containsIndex:index];

        if (isSelected)
        {
            [self deselectCellAtIndex:index];
        }
        else if (!invertSelection || isSelected)
        {
            [self selectCellAtIndex:index];
        }
        else
        {
            [self selectCellAtIndex:index];
        }
    }
    else
    {
        [super mouseDown:theEvent];
    }
}

@end
