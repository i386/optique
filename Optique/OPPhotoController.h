//
//  OPPhotoController.h
//  Optique
//
//  Created by James Dumay on 15/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OPPhotoViewController;

@interface OPPhotoController : NSViewController <NSMenuDelegate>

@property (strong) IBOutlet NSImageView *imageView;
@property (strong) IBOutlet NSMenu *contextMenu;
@property (strong) IBOutlet NSMenuItem *revealInFinderMenuItem;

-initWithPhotoViewController:(OPPhotoViewController*)photoViewController;

- (IBAction)revealInFinder:(id)sender;

- (IBAction)deletePhoto:(id)sender;

@end
