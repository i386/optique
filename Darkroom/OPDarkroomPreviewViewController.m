//
//  OPDarkroomEditorViewController.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPDarkroomPreviewViewController.h"
#import "OPDarkroomPreviewLayer.h"
#import "NSObject+PerformBlock.h"
#import "NSImage+CGImage.h"
#import "NSColor+Optique.h"
#import "NSWindow+FullScreen.h"

@interface OPDarkroomPreviewViewController ()

@property (weak) id<XPItem> item;
@property (strong) OPDarkroomPreviewLayer *previewLayer;
@property (weak) id<XPSidebarController> sidebarController;

@end

@implementation OPDarkroomPreviewViewController

- (id)initWithItem:(id<XPItem>)item sidebarController:(id<XPSidebarController>)sidebarController previewLayer:(CALayer*)layer
{
    NSBundle *thisBundle = [NSBundle bundleForClass:[OPDarkroomPreviewViewController class]];
    self = [super initWithNibName:@"OPDarkroomPreviewViewController" bundle:thisBundle];
    if (self) {
        _item = item;
        _sidebarController = sidebarController;
        _previewLayer = layer;
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.view.wantsLayer = YES;
    
    [self.view.layer addSublayer:_previewLayer];
    [_previewLayer setBounds:self.view.bounds];
    [_previewLayer setFrame:self.view.frame];
    
    
    //Load image in background
    [self performBlockInBackground:^{
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:_item.url];
        CGImageRef imageRef = [image CGImageRef];
        [self performBlockOnMainThread:^{
            _previewLayer.contents = (__bridge id)(imageRef);
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recalulateLayout:) name:NSViewFrameDidChangeNotification object:self.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recalulateLayout:) name:NSWindowDidEnterFullScreenNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recalulateLayout:) name:NSWindowDidExitFullScreenNotification object:self.view.window];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self.view];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEnterFullScreenNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidExitFullScreenNotification object:self.view.window];
}

-(void)recalulateLayout:(NSNotification*)notification
{
    [_previewLayer setBounds:self.view.bounds];
    [_previewLayer setFrame:self.view.frame];
    
    CGColorRef backgroundColor = [NSWindow isFullScreen] ? [[NSColor optiqueDarkFullscreenColor] CGColor] : [[NSColor colorWithCalibratedRed:0.40 green:0.40 blue:0.40 alpha:1.00] CGColor];
    
    self.view.layer.backgroundColor = backgroundColor;
    _previewLayer.borderColor = backgroundColor;
    _previewLayer.backgroundColor = backgroundColor;
    _previewLayer.borderWidth = 10.0;
}

-(void)removedView
{
    [_sidebarController hideSidebar];
}

@end
