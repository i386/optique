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
        [self.slideView setNeedsDisplay:YES];
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
        return [AVPlayerLayer playerLayerWithPlayer:player];
    }
    return nil;
}

-(void)slideView:(WHSlideView *)slideView layoutChangedForLayer:(CALayer *)layer
{
    CGColorRef backgroundColor = [NSWindow isFullScreen] ? [[NSColor optiqueDarkFullscreenColor] CGColor] : [[NSColor controlColor] CGColor];
    
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
    id<XPItem> item = [[[_item collection] allItems] objectAtIndex:index];
    if ([item type] == XPItemTypePhoto)
    {
        [self prepareLayer:layer forPhotoItem:item];
    }
}

-(void)slideView:(WHSlideView *)slideView layerClicked:(CALayer *)layer
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)layer;
    if (playerLayer && [playerLayer isKindOfClass:[AVPlayerLayer class]] && playerLayer.player.status == AVPlayerStatusReadyToPlay)
    {
        //TODO: find a better way to check for this
        if ([playerLayer.player rate] == 0.0)
        {
            [playerLayer.player play];
        }
        else
        {
            [playerLayer.player pause];
            [playerLayer.player seekToTime:kCMTimeZero];
        }
    }
}

-(void)prepareLayer:(CALayer *)layer forPhotoItem:(id<XPItem>)item
{
    CGImageRef imageRef = NULL;
    
    NSSize size = [[NSApplication sharedApplication] mainWindow].frame.size;
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)item.url, NULL);
    if (imageSource != nil)
    {
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        if (imageProperties != nil)
        {
            CFNumberRef pixelWidthRef  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
            CFNumberRef pixelHeightRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            CGFloat pixelWidth = [(__bridge NSNumber *)pixelWidthRef floatValue];
            CGFloat pixelHeight = [(__bridge NSNumber *)pixelHeightRef floatValue];
            CGFloat maxEdge = MAX(pixelWidth, pixelHeight);
            
            float maxEdgeSize = MAX(size.width, size.height);
            
            if (maxEdge > maxEdgeSize)
            {
                NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue,
                                                  kCGImageSourceCreateThumbnailWithTransform, kCFBooleanTrue,
                                                  kCGImageSourceCreateThumbnailFromImageAlways, [NSNumber numberWithFloat:maxEdgeSize],
                                                  kCGImageSourceThumbnailMaxPixelSize, kCFBooleanFalse, kCGImageSourceShouldCache, nil];
                
                imageRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)thumbnailOptions);
            }
            else
            {
                imageRef = [[[NSImage alloc] initWithContentsOfURL:item.url] CGImageRef];
            }
            
            CFRelease(imageProperties);
        }
        else
        {
            NSLog(@"Could not get image properties for '%@'", item.url);
        }
        
        CFRelease(imageSource);
    }
    else
    {
        NSLog(@"Could not create image src for '%@'", item.url);
    }
    
    if (imageRef)
    {
        [self performBlockOnMainThread:^{
            layer.contents = (id)CFBridgingRelease(imageRef);
        }];
    }
}

@end
