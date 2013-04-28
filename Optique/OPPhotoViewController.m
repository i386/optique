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

-(id)initWithPhotoAlbum:(OPPhotoAlbum *)album photo:(id<OPPhoto>)photo
{
    self = [super initWithNibName:@"OPPhotoViewController" bundle:nil];
    if (self) {
        _photoAlbum = album;
        _effectsState = NSOffState;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewSizeChanged:) name:NSViewFrameDidChangeNotification object:self.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionUpdated:) name:OPPhotoManagerDidUpdateCollection object:nil];
        
        //Page Controller
        [_pageController setArrangedObjects:_photoAlbum.allPhotos];
        _index = [_photoAlbum.allPhotos indexOfObject:photo];
        [_pageController setSelectedIndex:_index];
        [_pageController setTransitionStyle:NSPageControllerTransitionStyleHorizontalStrip];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEnterFullScreenNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidExitFullScreenNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self.view];
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
        
        [_photoAlbum deletePhoto:photo error:nil];
        
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
        NSSize windowSize = [[NSApplication sharedApplication] mainWindow].frame.size;
        _currentPhoto = object;
        viewController.representedObject = [_currentPhoto scaleImageToFitSize:windowSize];
        [self.controller updateNavigation];
    }
}

-(void)loadView
{
    [super loadView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewSizeChanged:) name:NSWindowDidEnterFullScreenNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewSizeChanged:) name:NSWindowDidExitFullScreenNotification object:self.view.window];
}

-(void)viewSizeChanged:(NSNotification*)notification
{
    [self performBlockOnMainThread:^{
        OPPhotoController *photoController = (OPPhotoController*)_pageController.selectedViewController;
//        [photoController.imageView setNeedsDisplay:YES];
        [photoController.view setNeedsDisplay:YES];
    }];
}

-(void)collectionUpdated:(NSNotification*)notification
{
    [self performBlockOnMainThreadAndWaitUntilDone:^{
        NSSize windowSize = [[NSApplication sharedApplication] mainWindow].frame.size;
        _pageController.selectedViewController.representedObject = [_currentPhoto scaleImageToFitSize:windowSize];
        
//        OPPhotoController *photoController = (OPPhotoController*)_pageController.selectedViewController;
//        [photoController.imageView setNeedsDisplay:YES];
//        [photoController.view setNeedsDisplay:YES];
        
        [_pageController.selectedViewController.view setNeedsDisplay:YES];
    }];
}

@end
