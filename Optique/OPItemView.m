//
//  OPPhotoView.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPItemView.h"
#import "OPPItemViewController.h"
#import "NSView+OptiqueBackground.h"
#import "NSPasteboard+XPItem.h"
#import "NSWindow+FullScreen.h"

@implementation OPItemView

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.window.isFullscreen)
    {
        [self drawDarkFullscreenBackground];
    }
    else
    {
        [self drawDarkBackground];
    }
}

-(void)mouseDown:(NSEvent *)theEvent
{
    if (theEvent.clickCount == 1)
    {
        NSUInteger width = 100;
        
        NSRect leftRect = NSMakeRect(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
        
        NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        if (NSPointInRect(pointInView, leftRect))
        {
            [_controller previous];
        };
        
        NSRect rightRect = NSMakeRect(self.frame.size.width - width, self.frame.origin.y, width, self.frame.size.height);
        if (NSPointInRect(pointInView, rightRect))
        {
            [_controller next];
        };
    }
}

- (void)keyDown:(NSEvent *)event
{
    NSString *characters = [event characters];
    
    unichar character = [characters characterAtIndex: 0];
    
    if (character == NSRightArrowFunctionKey)
    {
        [_controller next];
    }
    else if (character == NSLeftArrowFunctionKey)
    {
        [_controller previous];
    }
    else if (event.keyCode == 33)
    {
        [_controller backToCollection];
    }
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)copy:(id)sender
{
    NSURL *url = _controller.item.url;
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:@[url, image]];
}

@end
