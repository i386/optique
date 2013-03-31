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

@implementation OPPhotoView

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawBackground];
}

- (void)keyDown:(NSEvent *)event
{
    NSString *characters = [event characters];
    
    unichar character = [characters characterAtIndex: 0];
    
    if (character == NSRightArrowFunctionKey) {
        [_controller nextPhoto];
    } else if (character == NSLeftArrowFunctionKey) {
        [_controller previousPhoto];
    }
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

@end
