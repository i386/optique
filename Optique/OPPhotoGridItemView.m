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
#import "NSGraphicsContext+GraphicsContext.h"
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
    
    //Draw shadow
    [NSGraphicsContext withinGraphicsContext:^
    {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowBlurRadius = 3;
        shadow.shadowColor = [NSColor colorWithCalibratedRed:0.00 green:0.00 blue:0.00 alpha:0.1];
        shadow.shadowOffset = NSMakeSize(4, -4);
        [shadow set];
        
        [[NSColor whiteColor] set];
        NSRectFill(backgroundFrameRect);
        
        if (self.selected)
        {
            NSBezierPath *path = [NSBezierPath bezierPathWithRect:backgroundFrameRect];
            
            NSColor *focusRingColor = [NSColor colorWithCalibratedRed:0.22 green:0.46 blue:0.96 alpha:1.00];
            
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowColor = focusRingColor;
            shadow.shadowOffset = NSMakeSize(-1, 1);
            shadow.shadowBlurRadius = 5;
            [shadow set];
            [path fill];
            
            shadow.shadowOffset = NSMakeSize(1, -1);
            [shadow set];
            [path fill];
        }
    }];
    
    
    //Draw image
    [NSGraphicsContext withinGraphicsContext:^
    {
        NSRect imageRect = NSMakeRect(35, 35, 239, 155);
        [self.itemImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    }];
    
    
    //Draw label
    [NSGraphicsContext withinGraphicsContext:^
    {
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
    }];
}

- (void)viewDidChangeBackingProperties
{
    self.layer.contentsScale = [[self window] backingScaleFactor];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    NSArray *urls = [self selectedItemURLs];
    if (urls.count > 0)
    {
        NSLog(@"urls %@", urls);
        
        NSPoint downWinLocation = [theEvent locationInWindow];
        NSPoint point = [self convertPoint:downWinLocation fromView:nil];
        
        NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
        [pb declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
        [pb setPropertyList:urls forType:NSFilenamesPboardType];
        
        [self dragImage:self.itemImage at:point offset:NSZeroSize event:theEvent pasteboard:pb source:self slideBack:YES];
    }
}

-(NSArray*)selectedItemURLs
{
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    for (OPPhotoGridItemView *item in [self.gridView selectedItems])
    {
        if ([item.representedObject respondsToSelector:@selector(path)])
        {
            NSURL *url = (NSURL*)[item.representedObject path];
            [urls addObject:[url path]];
        }
    }
    return urls;
}

-(NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    switch (context)
    {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationCopy;
            break;
            
        default:
            return NSDragOperationNone;
            break;
    }
}

@end
