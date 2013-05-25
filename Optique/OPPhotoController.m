//
//  OPPhotoController.m
//  Optique
//
//  Created by James Dumay on 15/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoController.h"
#import "OPPhotoViewController.h"

@interface OPPhotoController ()
@property (weak) OPPhotoViewController *photoViewController;
@property (strong) NSMutableArray *sharingMenuItems;
@end

@implementation OPPhotoController

-(id)initWithPhotoViewController:(OPPhotoViewController *)photoViewController
{
    self = [super initWithNibName:@"OPPhotoController" bundle:nil];
    if (self) {
        _photoViewController = photoViewController;
    }
    return self;
}

-(id<XPPhoto>)visiblePhoto
{
    return _photoViewController.visiblePhoto;
}

-(NSWindow *)window
{
    return self.view.window;
}

- (IBAction)deletePhoto:(id)sender
{
    [_photoViewController deletePhoto];
}

-(void)loadView
{
    [super loadView];
    [OPExposureService photoManager:_photoViewController.collection.photoManager photoController:self];
}

@end
