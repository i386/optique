//
//  NSWindow+FullScreen.m
//  Optique
//
//  Created by James Dumay on 31/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSWindow+FullScreen.h"

@implementation NSWindow (FullScreen)

-(BOOL)isFullscreen
{
    return ([self styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask;
}

@end
