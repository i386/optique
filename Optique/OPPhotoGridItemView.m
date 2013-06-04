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
    NSRect imageRect = NSMakeRect(35, 35, 239, 155);
    
    NSColor *shadowColor = self.selected ? [NSColor alternateSelectedControlColor] : [NSColor controlShadowColor];
    
    [NSGraphicsContext withinGraphicsContext:^
    {
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:imageRect];
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = shadowColor;
        
        int positiveShadowOffset = 1;
        int negativeShadowOffset = -1;
        if (self.selected)
        {
            positiveShadowOffset = 3;
            negativeShadowOffset = -3;
        }
        
        shadow.shadowOffset = NSMakeSize(negativeShadowOffset, positiveShadowOffset);
        [shadow set];
        [path fill];
        
        shadow.shadowOffset = NSMakeSize(positiveShadowOffset, negativeShadowOffset);
        [shadow set];
        [path fill];
        
        shadow.shadowOffset = NSMakeSize(positiveShadowOffset, positiveShadowOffset);
        [shadow set];
        [path fill];
        
        shadow.shadowOffset = NSMakeSize(negativeShadowOffset, negativeShadowOffset);
        [shadow set];
        [path fill];
        
        if (!self.selected)
        {
            //Draw border around image so it doesn't blend with the background
            path.lineWidth = 0.3;
            [[NSColor blackColor] set];
            [path stroke];
        }
    }];
    
    //Draw image
    [NSGraphicsContext withinGraphicsContext:^
     {
         [self.itemImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
     }];
    
    
    //Draw label
    [NSGraphicsContext withinGraphicsContext:^
    {
        NSRect textRect = NSMakeRect(backgroundFrameRect.origin.x + 3,
                                     NSHeight(backgroundFrameRect) + 30,
                                     NSWidth(backgroundFrameRect) - 6,
                                     14);
        
        CATextLayer *label = [[CATextLayer alloc] init];
        [label setFont:@"Helvetica Neue Regular"];
        [label setFontSize:12];
        [label setFrame:textRect];
        [label setString:self.itemTitle];
        [label setAlignmentMode:kCAAlignmentCenter];
        [label setForegroundColor:[[NSColor blackColor] CGColor]];
        [label setBackgroundColor:[[NSColor optiqueBackgroundColor] CGColor]];
        
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
