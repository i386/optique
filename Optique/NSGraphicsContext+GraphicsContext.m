//
//  NSGraphicsContext+GraphicsContext.m
//  Optique
//
//  Created by James Dumay on 18/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSGraphicsContext+GraphicsContext.h"

@implementation NSGraphicsContext (GraphicsContext)

+(void)withinGraphicsContext:(void (^)(void))block
{
    [NSGraphicsContext saveGraphicsState];
    @try
    {
        block();
    }
    @finally
    {
        [NSGraphicsContext restoreGraphicsState];
    }
}

@end
