//
//  OPGridView.m
//  Optique
//
//  Created by James Dumay on 2/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoGridView.h"
#import "NSView+OptiqueBackground.h"

NSString *const OPPhotoGridViewReuseIdentifier = @"OPPhotoGridViewReuseIdentifier";

@implementation OPPhotoGridView

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawBackground];
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ( [[pboard types] containsObject:NSFilenamesPboardType] )
    {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

@end
