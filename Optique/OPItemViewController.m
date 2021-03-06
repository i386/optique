//
//  OPPhotoViewController.m
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "OPItemViewController.h"
#import "NSImage+CGImage.h"
#import "NSImage+Transform.h"
#import "NSColor+Optique.h"
#import "NSWindow+FullScreen.h"
#import "OPPlayerLayer.h"

@interface OPItemViewController()

@property (assign) NSInteger index;
@property (strong) NSMutableArray *sharingMenuItems;
@property (strong) NSOrderedSet *items;

@end

@implementation OPItemViewController

-(id)initWithItem:(id<XPItem>)item
{
    self = [super initWithNibName:@"OPItemViewController" bundle:nil];
    if (self) {
        _item = item;
        _items = _item.collection.allItems;
        _index = [_items indexOfObject:item];
        _sharingMenuItems = [NSMutableArray array];
    }
    return self;
}

-(void)awakeFromNib
{
    [XPExposureService collectionManager:_item.collection.collectionManager itemController:self];
    
    _contextMenu.delegate = self;
    self.slideView.contextMenu = _contextMenu;
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

-(CALayer *)imageLayer
{
    return _slideView.visibleLayer;
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

-(void)reload
{
    [_slideView reload];
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
        
        [item.collection deleteItem:item withCompletion:nil];
        
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
    id<XPItemCollection> collection = notification.userInfo[@"collection"];
    NSViewController *visibleViewController = self.controller.visibleViewController;
    
    if (collection && [self isEqualTo:visibleViewController])
    {
        //Get the new items
        _items = collection.allItems;
        
        //If the item still exists in the collection, hard reload the slide view
        if ([_items containsObject:_item])
        {
            [self performBlockOnMainThread:^{
                _slideView.delegate = self;
            }];
        }
        else //Pop to previous controller if the current item is no longer visible
        {
            [self performBlockOnMainThread:^{
                [self.controller popToPreviousViewController];
            }];
        }
    }
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
    id<XPItem> item = [_item.collection.allItems objectAtIndex:index];
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
    return _items.count;
}

-(NSUInteger)startingIndexForSlideView:(WHSlideView *)slideView
{
    return [_items indexOfObject:_item];
}

-(void)slideView:(WHSlideView *)slideView prepareLayer:(CALayer *)layer index:(NSUInteger)index
{
    id<XPItem> item = [_items objectAtIndex:index];
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
    if (item.url)
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
    else if ([item respondsToSelector:@selector(requestLocalCopyInCacheWhenDone:)])
    {
        [item requestLocalCopyInCacheWhenDone:^(NSError *error) {
            CGImageRef imageRef = XPItemGetImageRef(item, [[NSApplication sharedApplication] mainWindow].frame.size);
            
            if (imageRef)
            {
                [self performBlockOnMainThread:^{
                    BOOL requiresRefresh = layer.contents != nil;
                    
                    layer.contentsGravity = kCAGravityResizeAspect;
                    layer.contents = (id)CFBridgingRelease(imageRef);
                    
                    if (requiresRefresh)
                    {
                        [_slideView reload];
                    }
                }];
            }
        }];
    }
}

-(void)slideView:(WHSlideView *)slideView didShowLayer:(CALayer *)layer atIndex:(NSUInteger)index
{
    _item = _items[index];
}

-(void)slideView:(WHSlideView *)slideView didHideLayer:(CALayer *)layer
{
    OPPlayerLayer *playerLayer = (OPPlayerLayer*)layer;
    if (playerLayer && [playerLayer isKindOfClass:[OPPlayerLayer class]])
    {
        [playerLayer stopPlayback];
    }
}

-(void)removedView
{
    [_slideView visibleLayerMustStopPlaying];
}

@end
