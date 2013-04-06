//
//  NSImage+DrawAtPointWithShadow.m
//  Keynote Squeezer
//
//  Created by James Dumay on 16/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSImage+DrawAtPointWithShadow.h"

@implementation NSImage (DrawAtPointWithShadow)

-(void)drawAtPointWithShadow:(NSPoint)point
{
    [self drawAtPointWithShadow:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 offset:NSMakeSize(1, -1) radius:1 color:[NSColor blackColor]];
}

-(void)drawAtPointWithGlow:(NSPoint)point
{
    [self drawAtPointWithShadow:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 offset:NSMakeSize(1, -1) radius:5 color:[NSColor colorWithCalibratedRed:0.22 green:0.46 blue:0.96 alpha:1.00]];
    [self drawAtPointWithShadow:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 offset:NSMakeSize(-1, 1) radius:5 color:[NSColor colorWithCalibratedRed:0.22 green:0.46 blue:0.96 alpha:1.00]];
}

-(void)drawAtPointWithShadow:(NSPoint)point fromRect:(NSRect)fromRect operation:(NSCompositingOperation)op fraction:(CGFloat)delta offset:(NSSize)offset radius:(float)radius color:(NSColor*)color
{
    //Draw drop shadow
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetShadowWithColor(context, offset, radius, [color CGColor]);
    
    //Draw preview
    [self drawAtPoint:point fromRect:fromRect operation:op fraction:delta];
}

@end
