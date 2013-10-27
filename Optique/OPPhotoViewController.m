//
//  OPPhotoViewController.m
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OPPhotoViewController.h"
#import "OPPhotoView.h"
#import "NSImage+CGImage.h"
#import "NSImage+Transform.h"
#import "OPPhotoController.h"

@interface OPPhotoViewController()

@property (assign) NSInteger index;
@property (strong) NSMutableArray *sharingMenuItems;

@end

@implementation OPPhotoViewController

-(id)initWithPhotoCollection:(id<XPPhotoCollection>)collection photo:(id<XPPhoto>)photo
{
    self = [super initWithNibName:@"OPPhotoViewController" bundle:nil];
    if (self) {
        _collection = collection;
        _effectsState = NSOffState;
        _visiblePhoto = photo;
        _index = [_collection.allPhotos indexOfObject:photo];
        _sharingMenuItems = [NSMutableArray array];
    }
    return self;
}

-(void)awakeFromNib
{
    [XPExposureService photoManager:[_collection photoManager] photoController:self];
}

-(void)loadView
{
    [super loadView];
    
    //Setup page controller
    [_pageController setArrangedObjects:_collection.allPhotos];
    [_pageController setSelectedIndex:_index];
    
    //Subscribe to window & view events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowFullscreenStateChanged:) name:NSWindowDidEnterFullScreenNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowFullscreenStateChanged:) name:NSWindowDidExitFullScreenNotification object:self.view.window];
    
    //Update the views if the underlying collection has changed (for example, when the image is downloaded from the camera successfully
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionUpdated:) name:XPPhotoManagerDidUpdateCollection object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEnterFullScreenNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidExitFullScreenNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPPhotoManagerDidUpdateCollection object:nil];
}

-(NSString *)viewTitle
{
    return _visiblePhoto.title;
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)nextPhoto
{
    [_pageController navigateForward:self];
}

-(void)previousPhoto
{
    [_pageController navigateBack:self];
}

-(void)backToPhotoCollection
{
    [self.controller popToPreviousViewController];
}

-(void)deletePhoto
{
    NSString *message = [NSString stringWithFormat:@"Do you want to delete '%@'?", _visiblePhoto.title];
    
    NSBeginAlertSheet(message, @"Delete", nil, @"Cancel", self.view.window, self, @selector(deleteSheetDidEndShouldClose:returnCode:contextInfo:), nil, (void*)CFBridgingRetain(_visiblePhoto), @"This operation can not be undone.");
}

-(void)deleteSelected
{
    [self deletePhoto];
}

- (void)deleteSheetDidEndShouldClose: (NSWindow *)sheet
                          returnCode: (NSInteger)returnCode
                         contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        id<XPPhoto> photo = CFBridgingRelease(contextInfo);
        
        [_collection deletePhoto:photo withCompletion:nil];
        
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
    return [[OPPhotoController alloc] initWithPhotoViewController:self];
}

-(void)pageController:(NSPageController *)pageController prepareViewController:(NSViewController *)viewController withObject:(id)object
{
    if (object)
    {
        _visiblePhoto = object;
    }
    
    //Blank the current image so we dont get flashes of it when we async load the new image
    viewController.representedObject = nil;
    
    NSSize windowSize = [[NSApplication sharedApplication] mainWindow].frame.size;
    
    id photo = _visiblePhoto;
    if ([photo respondsToSelector:@selector(requestLocalCopyInCacheWhenDone:)])
    {
        [_visiblePhoto requestLocalCopyInCacheWhenDone:^(NSError *error) {
            [_visiblePhoto scaleImageToFitSize:windowSize withCompletionBlock:^void(NSImage *image) {
                viewController.representedObject = image;
            }];
        }];
    }
    else
    {
        [_visiblePhoto scaleImageToFitSize:windowSize withCompletionBlock:^void(NSImage *image) {
            viewController.representedObject = image;
        }];
    }
}

- (void)pageController:(NSPageController *)pageController didTransitionToObject:(id)object
{
}

-(void)windowFullscreenStateChanged:(NSNotification*)notification
{
    [self performBlockOnMainThread:^{
        OPPhotoController *photoController = (OPPhotoController*)_pageController.selectedViewController;
        [photoController.view setNeedsDisplay:YES];
        [photoController.imageView setNeedsDisplay:YES];
    }];
}

-(void)collectionUpdated:(NSNotification*)notification
{
    [self performBlockOnMainThreadAndWaitUntilDone:^{
        OPPhotoController *photoController = (OPPhotoController*)_pageController.selectedViewController;
        [photoController.view setNeedsDisplay:YES];
        [photoController.imageView setNeedsDisplay:YES];
    }];
}

-(BOOL)shareableItemsSelected
{
    return YES;
}

@end
