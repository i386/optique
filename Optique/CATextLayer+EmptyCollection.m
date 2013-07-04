//
//  CATextLayer+EmptyCollection.m
//  Optique
//
//  Created by James Dumay on 3/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "CATextLayer+EmptyCollection.h"
#import "NSColor+Optique.h"

@implementation CATextLayer (EmptyCollection)

-(void)setupEmptyCollectionMessage
{
    [self setFont:@"HelveticaNeue"];
    [self setFontSize:24];
    [self setAlignmentMode:kCAAlignmentCenter];
    [self setForegroundColor:[[NSColor disabledControlTextColor] CGColor]];
    [self setBackgroundColor:[[NSColor optiqueBackgroundColor] CGColor]];
    [self setWrapped:YES];
}

-(void)viewFrameChanged:(NSView *)view
{
    NSRect frame = NSMakeRect(view.frame.origin.x, view.frame.origin.y / 2, view.frame.size.width, (view.frame.size.height / 2) + 24);
    self.frame = frame;
}

@end
