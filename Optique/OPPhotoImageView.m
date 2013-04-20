//
//  OPPhotoImageView.m
//  Optique
//
//  Created by James Dumay on 20/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoImageView.h"

@implementation OPPhotoImageView

-(void)rightMouseDown:(NSEvent *)theEvent
{
    if (_contextMenu)
    {
        [NSMenu popUpContextMenu:_contextMenu withEvent:theEvent forView:self];
    }
}

@end
