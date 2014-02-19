//
//  OPPhotoViewController.m
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "OPPItemViewController.h"
#import "NSImage+CGImage.h"
#import "NSImage+Transform.h"
#import "NSColor+Optique.h"
#import "NSWindow+FullScreen.h"
#import "OPPlayerLayer.h"

@interface OPPItemViewController()

@property (assign) NSInteger index;
@property (strong) NSMutableArray *sharingMenuItems;

@end

@implementation OPPItemViewController

-(id)initWithItem:(id<XPItem>)item
{
    self = [super initWithNibName:@"OPPItemViewController" bundle:nil];
    if (self) {
        _item = item;
        _index = [[_item collection].allItems indexOfObject:item];
        _sharingMenuItems = [NSMutableArray array];
    }
    return self;
}

-(void)awakeFromNib
{
    [XPExposureService collectionManager:[[_item collection] collectionManager] itemController:self];
}

-(void)loadView
{
    [super loadView];
    
    //Subscribe to window & view events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowFullscreenStateChanged:) name:NSWindowDidEnterFullScreenNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowFullscreenStateChanged:) name:NSWindowDidExitFullScreenNotification object:self.view.window];
    
    //Update the views if the underlying collection has changed (for example, when the image is downloaded from the camera successfully
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionUpdated:) name:XPCollectionManagerDidUpdateCollection object:nil];
    
    [self.view.window makeFirstResponder:_slideView];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEnterFullScreenNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidExitFullScreenNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPCollectionManagerDidUpdateCollection object:nil];
}

-(NSString *)viewTitle
{
    return _item.title;
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)next
{
    [_slideView slideRight];
}

-(void)previous
{
    [_slideView slideLeft];
}

-(void)backToCollection
{
    [self.controller popToPreviousViewController];
}

-(void)deleteItem
{
    NSString *message = [NSString stringWithFormat:@"Do you want to delete '%@'?", _item.title];
    
    NSBeginAlertSheet(message, @"Delete", nil, @"Cancel", self.view.window, self, @selector(deleteSheetDidEndShouldClose:returnCode:contextInfo:), nil, (void*)CFBridgingRetain(_item), @"This operation can not be undone.");
}

-(void)deleteSelected
{
    [self deleteItem];
}

- (void)deleteSheetDidEndShouldClose: (NSWindow *)sheet
                          returnCode: (NSInteger)returnCode
                         contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        id<XPItem> item = CFBridgingRelease(contextInfo);
        
        [[_item collection] deleteItem:item withCompletion:nil];
        
        [self.controller popToPreviousViewController];
    }
}

-(NSWindow *)window
{
    return self.window;
}

-(void)windowFullscreenStateChanged:(NSNotification*)notification
{
    [self.slideView setNeedsDisplay:YES];
}

-(void)collectionUpdated:(NSNotification*)notification
{
    [self performBlockOnMainThreadAndWaitUntilDone:^{
        if ([[_item collection] isEqual:notification.userInfo[@"collection"]])
        {
            [self.slideView reload];
        }
    }];
}

-(BOOL)shareableItemsSelected
{
    return YES;
}

-(void)menuNeedsUpdate:(NSMenu *)menu
{
    [XPExposureService menuVisiblity:self.contextMenu item:_item];
}

-(CALayer *)slideView:(WHSlideView *)slideView newLayerForIndex:(NSUInteger)index
{
    id<XPItem> item = [[[_item collection] allItems] objectAtIndex:index];
    if ([item type] == XPItemTypeVideo)
    {
        AVPlayer *player = [AVPlayer playerWithURL:item.url];
        return [[OPPlayerLayer alloc] initWithPlayer:player];
    }
    return nil;
}

-(void)slideView:(WHSlideView *)slideView layoutChangedForLayer:(CALayer *)layer
{
    CGColorRef backgroundColor = [NSWindow isFullScreen] ? [[NSColor optiquePhotoSliderBackgroundFullscreenColor] CGColor] : [[NSColor optiquePhotoSliderBackgroundColor] CGColor];
    
    layer.borderColor = backgroundColor;
    layer.backgroundColor = backgroundColor;
    layer.borderWidth = 10.0;
}

-(NSUInteger)numberOfImagesForSlideView:(WHSlideView *)slideView
{
    return [[_item collection] allItems].count;
}

-(NSUInteger)startingIndexForSlideView:(WHSlideView *)slideView
{
    return [[[_item collection] allItems] indexOfObject:_item];
}

-(void)slideView:(WHSlideView *)slideView prepareLayer:(CALayer *)layer index:(NSUInteger)index
{
    layer.contentsGravity = kCAGravityResizeAspect;
    
    id<XPItem> item = [[[_item collection] allItems] objectAtIndex:index];
    if ([item type] == XPItemTypePhoto)
    {
        [self prepareLayer:layer forPhotoItem:item];
    }
}

-(void)slideView:(WHSlideView *)slideView layerClicked:(CALayer *)layer
{
    OPPlayerLayer *playerLayer = (OPPlayerLayer*)layer;
    if (playerLayer && [playerLayer isKindOfClass:[OPPlayerLayer class]])
    {
        [playerLayer togglePlayback];
    }
}

-(void)slideView:(WHSlideView *)slideView mouseMovedInLayer:(CALayer *)layer point:(NSPoint)point
{
    OPPlayerLayer *playerLayer = (OPPlayerLayer*)layer;
    if (playerLayer && [playerLayer isKindOfClass:[OPPlayerLayer class]])
    {
        [playerLayer showStopButton];
    }
}

-(void)prepareLayer:(CALayer *)layer forPhotoItem:(id<XPItem>)item
{
    CGImageRef imageRef = XPItemGetImageRef(item, [[NSApplication sharedApplication] mainWindow].frame.size);
    
    if (imageRef)
    {
        [self performBlockOnMainThread:^{
            layer.contentsGravity = kCAGravityResizeAspect;
            layer.contents = (id)CFBridgingRelease(imageRef);
        }];
    }
}

@end
