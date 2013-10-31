//
//  OPPhotoController.h
//  Optique
//
//  Created by James Dumay on 15/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OPPhotoViewController;

@interface OPPhotoController : NSViewController <NSMenuDelegate, XPPhotoController, XPSharingService>

@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSMenu *contextMenu;

-initWithPhotoViewController:(OPPhotoViewController*)photoViewController;

- (IBAction)deletePhoto:(id)sender;

@end
