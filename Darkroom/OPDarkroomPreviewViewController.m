//
//  OPDarkroomEditorViewController.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPDarkroomPreviewViewController.h"
#import "OPDarkroomPreviewView.h"

#import "NSObject+PerformBlock.h"
#import "NSImage+CGImage.h"
#import "NSColor+Optique.h"
#import "NSWindow+FullScreen.h"

@interface OPDarkroomPreviewViewController ()

@property (weak) id<XPItem> item;
@property (strong) CALayer *previewLayer;
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
    
    OPDarkroomPreviewView *view = (OPDarkroomPreviewView*)self.view;
    view.previewLayer = _previewLayer;
    view.item = _item;
}

-(void)removedView
{
    [_sidebarController hideSidebar];
}

@end
