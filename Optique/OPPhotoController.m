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

- (IBAction)revealInFinder:(id)sender
{
    [_photoViewController revealInFinder];
}

- (IBAction)deletePhoto:(id)sender
{
    [_photoViewController deletePhoto];
}

-(void)menuNeedsUpdate:(NSMenu *)menu
{
    [_revealInFinderMenuItem setHidden:!_photoViewController.collection.isStoredOnFileSystem];
}

@end
