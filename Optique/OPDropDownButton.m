//
//  OPDropDownButton.m
//  Optique
//
//  Created by James Dumay on 27/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPDropDownButton.h"

@implementation OPDropDownButton

-(void)awakeFromNib
{
    popUpCell = [[NSPopUpButtonCell alloc] initTextCell:@""];
    [popUpCell setPullsDown:YES];
    [popUpCell setPreferredEdge:NSMaxYEdge];
}

- (void)runPopUp:(NSEvent *)theEvent
{
    [[[self menu] delegate] menuNeedsUpdate:self.menu];
    
    // create the menu the popup will use
    NSMenu *popUpMenu = [[self menu] copy];
    [popUpMenu insertItemWithTitle:@"" action:NULL keyEquivalent:@"" atIndex:0];    // blank item at top
    [popUpCell setMenu:popUpMenu];
    
    // and show it
    [popUpCell performClickWithFrame:[self bounds] inView:self];
    
    [self setNeedsDisplay: YES];
}

- (void)mouseDown:(NSEvent*)theEvent
{
    if (self.isEnabled)
    {
        [self runPopUp:theEvent];
    }
}

@end
