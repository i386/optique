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
#import "NSColor+Optique.h"

@implementation OPPhotoGridItemView

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        [self setWantsLayer:YES];
    }
    return self;
}

-(void)drawRect:(NSRect)dirtyRect
{
    NSRect backgroundFrameRect = NSMakeRect(dirtyRect.origin.x + 25, dirtyRect.origin.y + 25, dirtyRect.size.width - 50, dirtyRect.size.height - 50);
    
    NSColor *backgroundColor = self.selected ? [NSColor optiqueSelectedBackgroundColor] : [NSColor optiqueBackgroundColor];
    
    [NSGraphicsContext withinGraphicsContext:^
    {
       if (self.selected)
       {
           [backgroundColor set];
           NSRectFill(dirtyRect);
       }
    }];
    
    [NSGraphicsContext withinGraphicsContext:^
    {
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:backgroundFrameRect];
        path.lineWidth = 0.7;
        [[NSColor blackColor] set];
        [path stroke];
    }];
    
    //Draw image
    [NSGraphicsContext withinGraphicsContext:^
     {
         [self.itemImage drawInRect:backgroundFrameRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
     }];
    
    
    //Draw label
    [NSGraphicsContext withinGraphicsContext:^
    {
        NSRect textRect = NSMakeRect(backgroundFrameRect.origin.x,
                                     NSHeight(backgroundFrameRect) + 30,
                                     NSWidth(backgroundFrameRect),
                                     30);
        
        CATextLayer *label = [[CATextLayer alloc] init];
        [label setFont:@"HelveticaNeue-Light"];
        [label setFontSize:14];
        [label setFrame:textRect];
        [label setString:self.itemTitle];
        [label setAlignmentMode:kCAAlignmentCenter];
        [label setForegroundColor:[[NSColor optiqueTextColor] CGColor]];
        [label setBackgroundColor:[backgroundColor CGColor]];
        [label setTruncationMode:kCATruncationMiddle];
        
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
