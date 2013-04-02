//
//  OPAlbumItemView.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CNGridView/CNGridViewItemLayout.h>
#import "OPPhotoGridItemView.h"
#import "NSView+OptiqueBackground.h"
#import "OPTextLayer.h"

@implementation OPPhotoGridItemView

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSCenterTextAlignment];
        
        NSFont *font = [NSFont fontWithName:@"Helvetica Neue" size:12.0];
        _attrsDictionary = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: style};
        
        [self setWantsLayer:YES];
    }
    return self;
}

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
    
    [NSGraphicsContext restoreGraphicsState];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSRect textRect = NSMakeRect(backgroundFrameRect.origin.x + 3,
                                 NSHeight(backgroundFrameRect) + 30,
                                 NSWidth(backgroundFrameRect) - 6,
                                 14);
    
    OPTextLayer *label = [[OPTextLayer alloc] init];
    [label setFont:@"Helvetica Neue Regular"];
    [label setFontSize:12];
    [label setFrame:textRect];
    [label setString:self.itemTitle];
    [label setAlignmentMode:kCAAlignmentCenter];
    [label setForegroundColor:[[NSColor blackColor] CGColor]];
    [label setBackgroundColor:[[NSView gradientBottomColor] CGColor]];
    
    for (CALayer *layer in self.layer.sublayers)
    {
        [layer removeFromSuperlayer];
    }
    
    [self.layer addSublayer:label];

    [NSGraphicsContext restoreGraphicsState];
}

- (void)viewDidChangeBackingProperties
{
    self.layer.contentsScale = [[self window] backingScaleFactor];
}

@end
