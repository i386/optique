//
//  OPPhotoViewController.m
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OPPItemViewController.h"
#import "OPItemView.h"
#import "NSImage+CGImage.h"
#import "NSImage+Transform.h"
#import "OPItemController.h"

@interface OPPItemViewController()

@property (assign) NSInteger index;
@property (strong) NSMutableArray *sharingMenuItems;

@end

@implementation OPPItemViewController

-(id)initWithItemCollection:(id<XPItemCollection>)collection item:(id<XPItem>)item
{
    self = [super initWithNibName:@"OPPItemViewController" bundle:nil];
    if (self) {
        _collection = collection;
        _effectsState = NSOffState;
        _item = item;
        _index = [_collection.allItems indexOfObject:item];
        _sharingMenuItems = [NSMutableArray array];
    }
    return self;
}

-(void)awakeFromNib
{
    [XPExposureService collectionManager:[_collection collectionManager] itemController:self];
}

-(void)loadView
{
    [super loadView];
    
    //Setup page controller
    [_pageController setArrangedObjects:_collection.allItems.array];
    [_pageController setSelectedIndex:_index];
    
    //Subscribe to window & view events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowFullscreenStateChanged:) name:NSWindowDidEnterFullScreenNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowFullscreenStateChanged:) name:NSWindowDidExitFullScreenNotification object:self.view.window];
    
    //Update the views if the underlying collection has changed (for example, when the image is downloaded from the camera successfully
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionUpdated:) name:XPCollectionManagerDidUpdateCollection object:nil];
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
    [_pageController navigateForward:self];
}

-(void)previous
{
    [_pageController navigateBack:self];
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
        
        [_collection deleteItem:item withCompletion:nil];
        
        [self.controller popToPreviousViewController];
    }
}

-(NSWindow *)window
{
    return self.window;
}

-(NSString *)pageController:(NSPageController *)pageController identifierForObject:(id)object
{
    return @"photo";
}

-(NSViewController *)pageController:(NSPageController *)pageController viewControllerForIdentifier:(NSString *)identifier
{
    return [[OPItemController alloc] initWithItemViewController:self];
}

-(void)pageController:(NSPageController *)pageController prepareViewController:(NSViewController *)viewController withObject:(id<XPItem>)item
{
    
    //Blank the current image so we dont get flashes of it when we async load the new image
    viewController.representedObject = nil;
    
    if ([item respondsToSelector:@selector(requestLocalCopyInCacheWhenDone:)])
    {
        [item requestLocalCopyInCacheWhenDone:^(NSError *error) {
            viewController.representedObject = item;
        }];
    }
    else
    {
        viewController.representedObject = item;
    }
}

-(void)windowFullscreenStateChanged:(NSNotification*)notification
{
    [self performBlockOnMainThread:^{
        OPItemController *controller = (OPItemController*)_pageController.selectedViewController;
        [controller.view setNeedsDisplay:YES];
        [controller.imageView setNeedsDisplay:YES];
    }];
}

- (void)pageController:(NSPageController *)pageController didTransitionToObject:(id)object
{
}

-(void)collectionUpdated:(NSNotification*)notification
{
    [self performBlockOnMainThreadAndWaitUntilDone:^{
        OPItemController *controller = (OPItemController*)_pageController.selectedViewController;
        [controller.view setNeedsDisplay:YES];
        [controller.imageView setNeedsDisplay:YES];
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


@end
