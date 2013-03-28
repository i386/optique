//
//  OPPhotoItemView.m
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoItemView.h"

@implementation OPPhotoItemView

-(void)mouseDown:(NSEvent *)theEvent {
	[super mouseDown:theEvent];
	
	// check for click count above one, which we assume means it's a double click
	if([theEvent clickCount] > 1)
    {
        if(delegate && [delegate respondsToSelector:@selector(doubleClick:)])
        {
			[delegate performSelector:@selector(doubleClick:) withObject:self];
		}
	}
}

@end
