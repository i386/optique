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
        
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }
    return self;
}

-(void)mouseDown:(NSEvent *)theEvent
{
    NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger index = [self indexForCellAtPoint:pointInView];
    
    if (_isSelectionSticky && [theEvent clickCount] == 1)
    {
        [self toggleSelectedState:theEvent];
    }
    else if (_isSelectionSticky && index != NSNotFound && [theEvent clickCount] == 2)
    {
        [NSRunLoop cancelPreviousPerformRequestsWithTarget:self];
        [self.delegate gridView:self doubleClickedCellForItemAtIndex:index];
        [self deselectAll:nil];
    }
    else
    {
        [super mouseDown:theEvent];
    }
}

-(void)toggleSelectedState:(NSEvent*)theEvent
{
    NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger index = [self indexForCellAtPoint:pointInView];
    
    if (index != NSNotFound)
    {
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
        [self deselectAll:nil];
    }
}

@end
