//
//  OPProgressLayer.m
//  Optique
//
//  Created by James Dumay on 29/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//
// Portions are dervived from LLACircularProgressView by Lukas Lipka
// https://github.com/lipka/LLACircularProgressView
//
// The MIT License (MIT)
//
// Copyright (c) 2013 Lukas Lipka
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "OPProgressLayer.h"
#import "NSBezierPath+BezierPathQuartzUtilities.h"

@interface OPProgressLayer ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation OPProgressLayer

-(id)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    _thickness = 3;
    _progressTintColor = [NSColor whiteColor]; // [NSColor colorWithCalibratedRed:0.00 green:0.48 blue:1.00 alpha:1.00];
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.strokeColor = [_progressTintColor CGColor];
    _progressLayer.strokeEnd = 0;
    _progressLayer.fillColor = nil;
    _progressLayer.lineWidth = _thickness;
    [self addSublayer:_progressLayer];
}

-(void)layoutSublayers
{
    [super layoutSublayers];
    
    self.progressLayer.frame = self.bounds;
    
    [self updatePath];
}

#pragma mark - Accessors

-(void)setThickness:(float)thickness
{
    _thickness = thickness;
    _progressLayer.lineWidth = _thickness;
    
    [self setNeedsDisplay];
}

- (void)setProgress:(float)progress
{
    [self setNeedsDisplay];
    [self setProgress:progress animated:NO];
}

-(void)drawInContext:(CGContextRef)ctx
{
    CGContextSetStrokeColorWithColor(ctx, self.progressTintColor.CGColor);
    CGContextSetFillColorWithColor(ctx, [[NSColor colorWithCalibratedRed:0.30 green:0.30 blue:0.30 alpha:0.30] CGColor]);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(self.bounds, 1, 1));
    CGContextFillEllipseInRect(ctx, CGRectInset(self.bounds, 1, 1));
    
    //Set fill for triangle/square
    CGContextSetFillColorWithColor(ctx, self.progressTintColor.CGColor);
    
    if (_progress > 0) //Square
    {
        float sideLength = self.bounds.size.width / 3;
        
        CGRect stopRect;
        stopRect.size.width = sideLength;
        stopRect.size.height = sideLength;
        
        stopRect.origin.x = sideLength;
        stopRect.origin.y = sideLength;
        
        CGContextFillRect(ctx, CGRectIntegral(stopRect));
    }
    else //Triangle
    {
        float sideLength = self.bounds.size.width / 2;

        float radius = self.bounds.size.width / 2;
        
        NSPoint pointA = NSMakePoint((radius*2)/3, (radius/2));
        NSPoint pointB = NSMakePoint(pointA.x, pointA.y + sideLength);
        NSPoint pointC = NSMakePoint(pointA.x + ((sideLength*sqrt(3))/2), pointA.y + (sideLength/2));
        
        [self drawTriangleWithContext:ctx pointA:pointA pointB:pointB pointC:pointC];
    }
}

-(void)drawTriangleWithContext:(CGContextRef)context pointA:(NSPoint)pointA pointB:(NSPoint)pointB pointC:(NSPoint)pointC
{
    CGContextMoveToPoint(context, pointA.x, pointA.y);
    CGContextAddLineToPoint(context, pointB.x, pointB.y);
    CGContextAddLineToPoint(context, pointC.x, pointC.y);
    CGContextAddLineToPoint(context, pointA.x, pointA.y);
    CGContextFillPath(context);
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    if (progress > 0)
    {
        if (animated)
        {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.fromValue = self.progress == 0 ? @0 : nil;
            animation.toValue = [NSNumber numberWithFloat:progress];
            animation.duration = 1;
            self.progressLayer.strokeEnd = progress;
            [self.progressLayer addAnimation:animation forKey:@"animation"];
        }
        else
        {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.progressLayer.strokeEnd = progress;
            [CATransaction commit];
        }
    }
    else
    {
        self.progressLayer.strokeEnd = 0.0f;
        [self.progressLayer removeAnimationForKey:@"animation"];
    }
    
    _progress = progress;
}

- (void)updatePath
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithArcWithCenter:center
                                     radius:self.bounds.size.width / 2 - 2
                                 startAngle:-M_PI_2
                                   endAngle:-M_PI_2 + _thickness * M_PI clockwise:YES];
    
    self.progressLayer.path = [path quartzPath];
}

@end
