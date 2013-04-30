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
#import "OPEffectProcessedImageRef.h"
#import "NSImage+Transform.h"
#import "OPPhotoController.h"
#import "OPPhotoManager.h"

@interface OPPhotoViewController() {
    NSInteger _index;
    id<OPPhoto> _currentPhoto;
}
@end

@implementation OPPhotoViewController

-(id)initWithPhotoCollection:(id<OPPhotoCollection>)collection photo:(id<OPPhoto>)photo
{
    self = [super initWithNibName:@"OPPhotoViewController" bundle:nil];
    if (self) {
        _collection = collection;
        _effectsState = NSOffState;
        _currentPhoto = photo;
        _index = [_collection.allPhotos indexOfObject:photo];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    //Setup page controller
    [_pageController setArrangedObjects:_collection.allPhotos];
    [_pageController setTransitionStyle:NSPageControllerTransitionStyleHorizontalStrip];
    [_pageController setSelectedIndex:_index];
    
    //Subscribe to window & view events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowFullscreenStateChanged:) name:NSWindowDidEnterFullScreenNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowFullscreenStateChanged:) name:NSWindowDidExitFullScreenNotification object:self.view.window];
    
    //Update the views if the underlying collection has changed (for example, when the image is downloaded from the camera successfully
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionUpdated:) name:OPPhotoManagerDidUpdateCollection object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEnterFullScreenNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidExitFullScreenNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPPhotoManagerDidUpdateCollection object:nil];
}

-(NSString *)viewTitle
{
    return _currentPhoto.title;
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
    NSString *message = [NSString stringWithFormat:@"Do you want to delete '%@'?", _currentPhoto.title];
    
    NSBeginAlertSheet(message, @"Delete", nil, @"Cancel", self.view.window, self, @selector(deleteSheetDidEndShouldClose:returnCode:contextInfo:), nil, (void*)CFBridgingRetain(_currentPhoto), @"This operation can not be undone.");
}

- (void)deleteSheetDidEndShouldClose: (NSWindow *)sheet
                          returnCode: (NSInteger)returnCode
                         contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        id<OPPhoto> photo = CFBridgingRelease(contextInfo);
        
        [_collection deletePhoto:photo withCompletion:nil];
        
        [self.controller popToPreviousViewController];
    }
}

-(void)revealInFinder
{
//    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[_currentPhoto.path]];
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
        _currentPhoto = object;
    }
    
    NSSize windowSize = [[NSApplication sharedApplication] mainWindow].frame.size;
    [_currentPhoto scaleImageToFitSize:windowSize withCompletionBlock:^void(NSImage *image) {
        viewController.representedObject = image;
    }];
    
    [self.controller updateNavigation];
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

@end
