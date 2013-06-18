//
//  OPSegmentedCell.m
//  Optique
//
//  Created by James Dumay on 18/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPSegmentedCell.h"
#import "NSColor+Optique.h"
#import "NSGraphicsContext+GraphicsContext.h"

@implementation OPSegmentedCell

CGMutablePathRef createRoundedCornerPath(CGRect rect, CGFloat cornerRadius) {
    
    // create a mutable path
    CGMutablePathRef path = CGPathCreateMutable();
    
    // get the 4 corners of the rect
    CGPoint topLeft = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint topRight = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    CGPoint bottomRight = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGPoint bottomLeft = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    
    // move to top left
    CGPathMoveToPoint(path, NULL, topLeft.x + cornerRadius, topLeft.y);
    
    // add top line
    CGPathAddLineToPoint(path, NULL, topRight.x - cornerRadius, topRight.y);
    
    // add top right curve
    CGPathAddQuadCurveToPoint(path, NULL, topRight.x, topRight.y, topRight.x, topRight.y + cornerRadius);
    
    // add right line
    CGPathAddLineToPoint(path, NULL, bottomRight.x, bottomRight.y - cornerRadius);
    
    // add bottom right curve
    CGPathAddQuadCurveToPoint(path, NULL, bottomRight.x, bottomRight.y, bottomRight.x - cornerRadius, bottomRight.y);
    
    // add bottom line
    CGPathAddLineToPoint(path, NULL, bottomLeft.x + cornerRadius, bottomLeft.y);
    
    // add bottom left curve
    CGPathAddQuadCurveToPoint(path, NULL, bottomLeft.x, bottomLeft.y, bottomLeft.x, bottomLeft.y - cornerRadius);
    
    // add left line
    CGPathAddLineToPoint(path, NULL, topLeft.x, topLeft.y + cornerRadius);
    
    // add top left curve
    CGPathAddQuadCurveToPoint(path, NULL, topLeft.x, topLeft.y, topLeft.x + cornerRadius, topLeft.y);
    
    // return the path
    return path;
}

void drawRect(CGRect rect, CGContextRef context, CGColorRef backgroundColor, CGColorRef borderColor)
{
    // constants
    const CGFloat outlineStrokeWidth = 1.0f;
    const CGFloat outlineCornerRadius = 3.0f;
    
    CGContextSetFillColorWithColor(context, backgroundColor);
    CGContextFillRect(context, rect);
    
    // inset the rect because half of the stroke applied to this path will be on the outside
    CGRect insetRect = CGRectInset(rect, outlineStrokeWidth/2.0f, outlineStrokeWidth/2.0f);
    
    // get our rounded rect as a path
    CGMutablePathRef path = createRoundedCornerPath(insetRect, outlineCornerRadius);
    
    // add the path to the context
    CGContextAddPath(context, path);
    
    // set the stroke params
    CGContextSetStrokeColorWithColor(context, borderColor);
    CGContextSetLineWidth(context, outlineStrokeWidth);
    
    // draw the path
    CGContextDrawPath(context, kCGPathStroke);
    
    // release the path
    CGPathRelease(path);
}

-(void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView
{
    if (self.selectedSegment == segment)
    {
        [NSGraphicsContext withinGraphicsContext:^{
            NSRect newFrame = NSMakeRect(frame.origin.x - 1, frame.origin.y - 2, frame.size.width, frame.size.height + 5);
            [[NSColor optiqueTitlebarBorderColor] set];
            
            if (self.selectedSegment == 0)
            {
                newFrame = NSMakeRect(frame.origin.x - 1, frame.origin.y - 1, frame.size.width + 1, frame.size.height + 5);
                NSRectFill(newFrame);
                
                newFrame = NSMakeRect(frame.origin.x - 2, frame.origin.y - 2, frame.size.width + 2, frame.size.height + 5);
                NSRectFill(newFrame);
                
                newFrame = NSMakeRect(frame.origin.x - 1, frame.origin.y - 3, frame.size.width + 1, frame.size.height + 5);
                NSRectFill(newFrame);
            }
            
            if (self.selectedSegment == 1)
            {
                newFrame = NSMakeRect(frame.origin.x + 0, frame.origin.y - 1, frame.size.width + 1, frame.size.height + 5);
                NSRectFill(newFrame);
                
                newFrame = NSMakeRect(frame.origin.x + 0, frame.origin.y - 2, frame.size.width + 2, frame.size.height + 5);
                NSRectFill(newFrame);
                
                newFrame = NSMakeRect(frame.origin.x + 0, frame.origin.y - 3, frame.size.width + 1, frame.size.height + 5);
                NSRectFill(newFrame);
            }
        }];
    }
    
    [super drawSegment:segment inFrame:frame withView:controlView];
}

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [NSGraphicsContext withinGraphicsContext:^{
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        drawRect(cellFrame, context, [[NSColor optiqueTitlebarColor] CGColor], [[NSColor optiqueTitlebarBorderColor] CGColor]);
    }];
    [super drawWithFrame:cellFrame inView:controlView];
}

-(void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [NSGraphicsContext withinGraphicsContext:^{
        [[NSColor optiqueTitlebarColor] set];
        NSRect newFrame = NSMakeRect(cellFrame.origin.x - 2, cellFrame.origin.y - 2, cellFrame.size.width + 4, cellFrame.size.height + 5);
        NSLog(@"cellframe %@", NSStringFromRect(newFrame));
        NSRectFill(newFrame);
        
        
    }];
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
