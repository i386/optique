//
//  OPPlayerView.m
//  Optique
//
//  Created by James Dumay on 18/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface OPPlayerView()

@property (strong) NSDraggingSession *draggingSession;

@end

@implementation OPPlayerView

-(void)mouseDragged:(NSEvent *)theEvent
{
    NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:self.representedObject];
    _draggingSession = [self beginDraggingSessionWithItems:@[dragItem] event:theEvent source:self];
    [_draggingSession setDraggingFormation:NSDraggingFormationStack];
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    return context == NSDraggingContextWithinApplication ? NSDragOperationCopy : NSDragOperationNone;
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
    _draggingSession = nil;
}

-(void)setRepresentedObject:(id<XPItem>)representedObject
{
    _representedObject = representedObject;
    self.player = [[AVPlayer alloc] initWithURL:[representedObject url]];
}

@end
