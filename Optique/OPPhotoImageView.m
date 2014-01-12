//
//  OPPhotoImageView.m
//  Optique
//
//  Created by James Dumay on 20/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoImageView.h"

@interface OPPhotoImageView()

@property (strong) NSDraggingSession *draggingSession;

@end

@implementation OPPhotoImageView

-(void)rightMouseDown:(NSEvent *)theEvent
{
    if (_contextMenu)
    {
        [NSMenu popUpContextMenu:_contextMenu withEvent:theEvent forView:self];
    }
}

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

@end
