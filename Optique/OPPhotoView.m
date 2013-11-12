//
//  OPPhotoView.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoView.h"
#import "OPPhotoViewController.h"
#import "NSView+OptiqueBackground.h"
#import "NSPasteboard+XPPhoto.h"
#import "NSWindow+FullScreen.h"

@implementation OPPhotoView

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

- (void)keyDown:(NSEvent *)event
{
    NSString *characters = [event characters];
    
    unichar character = [characters characterAtIndex: 0];
    
    if (character == NSRightArrowFunctionKey)
    {
        [_controller nextPhoto];
    }
    else if (character == NSLeftArrowFunctionKey)
    {
        [_controller previousPhoto];
    }
    else if (event.keyCode == 33)
    {
        [_controller backToPhotoCollection];
    }
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)copy:(id)sender
{
    NSURL *url = _controller.visiblePhoto.url;
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:@[url, image]];
}

@end
