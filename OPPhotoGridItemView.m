//
//  OPAlbumItemView.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoGridItemView.h"

@implementation OPPhotoGridItemView

-(void)drawRect:(NSRect)dirtyRect
{
    NSRect backgroundFrameRect = NSMakeRect(25, 25, 260, 175);
    
    [NSGraphicsContext saveGraphicsState];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 3;
    shadow.shadowColor = [NSColor colorWithCalibratedRed:0.00 green:0.00 blue:0.00 alpha:0.1];
    shadow.shadowOffset = NSMakeSize(4, -4);
    [shadow set];
    
    [[NSColor whiteColor] set];
    NSRectFill(backgroundFrameRect);
    
    [NSGraphicsContext restoreGraphicsState];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSRect imageRect = NSMakeRect(35, 35, 239, 155);
    [self.itemImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
    NSRect textRect = NSMakeRect(backgroundFrameRect.origin.x + 3,
                                 NSHeight(backgroundFrameRect),
                                 NSWidth(backgroundFrameRect) - 6,
                                 14);
    
    [self.itemTitle drawInRect:textRect withAttributes:nil];
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
