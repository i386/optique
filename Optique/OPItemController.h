//
//  OPPhotoController.h
//  Optique
//
//  Created by James Dumay on 15/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPPhotoImageView.h"

@class OPPItemViewController;

@interface OPItemController : NSViewController <NSMenuDelegate, XPItemController, XPSharingService>

@property (weak) IBOutlet OPPhotoImageView *imageView;
@property (weak) IBOutlet NSMenu *contextMenu;

-initWithPhotoViewController:(OPPItemViewController*)itemViewController;

- (IBAction)deletePhoto:(id)sender;

@end
