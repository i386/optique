//
//  OPDarkroomPreviewView.m
//  Optique
//
//  Created by James Dumay on 2/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPDarkroomPreviewView.h"
#import "NSObject+PerformBlock.h"
#import "NSImage+CGImage.h"
#import "NSColor+Optique.h"
#import "NSWindow+FullScreen.h"

@interface OPDarkroomPreviewView ()

@end

@implementation OPDarkroomPreviewView

-(void)setItem:(id<XPItem>)item
{
    _item = item;
    
    [self performBlockInBackground:^{
        CGImageRef imageRef = XPItemGetImageRef(_item, self.bounds.size);
        [self performBlockOnMainThread:^{
            _previewLayer.contents = (__bridge id)(imageRef);
        }];
    }];
}

-(void)setPreviewLayer:(OPDarkroomPreviewLayer *)previewLayer
{
    _previewLayer = previewLayer;
    [self.layer addSublayer:_previewLayer];
    [self recalulateLayout:nil];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.acceptsTouchEvents = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recalulateLayout:) name:NSViewFrameDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recalulateLayout:) name:NSWindowDidEnterFullScreenNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recalulateLayout:) name:NSWindowDidExitFullScreenNotification object:self.window];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEnterFullScreenNotification object:self.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidExitFullScreenNotification object:self.window];
}

-(void)recalulateLayout:(NSNotification*)notification
{
    [_previewLayer setBounds:self.bounds];
    [_previewLayer setFrame:self.frame];
    
    CGColorRef backgroundColor = [NSWindow isFullScreen] ? [[NSColor optiquePhotoSliderBackgroundFullscreenColor] CGColor] : [[NSColor colorWithCalibratedRed:0.40 green:0.40 blue:0.40 alpha:1.00] CGColor];
    
    self.layer.backgroundColor = backgroundColor;
    _previewLayer.borderColor = backgroundColor;
    _previewLayer.backgroundColor = backgroundColor;
    _previewLayer.borderWidth = 10.0;
    
    CGImageRef imageRef = XPItemGetImageRef(_item, self.bounds.size);
    [self performBlockOnMainThread:^{
        _previewLayer.contents = (__bridge id)(imageRef);
    }];
}

@end
