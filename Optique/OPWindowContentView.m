//
//  OPWindowContentView.m
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPWindowContentView.h"
#import "NSView+OptiqueBackground.h"

@implementation OPWindowContentView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawBackground];
}

-(void)keyDown:(NSEvent *)event
{
    //Escape key
    if (event.keyCode == 53 && [self.window.windowController respondsToSelector:@selector(navigateBackward)])
    {
        [self.window.windowController performSelector:@selector(navigateBackward)];
    }
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

@end
