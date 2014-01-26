//
//  OPPhotoController.h
//  Optique
//
//  Created by James Dumay on 15/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPPlayerView.h"
#import "OPPhotoImageView.h"

@class OPPItemViewController;

@interface OPItemController : NSViewController <NSMenuDelegate, XPItemController, XPSharingService>

@property (weak) IBOutlet OPPhotoImageView *imageView;
@property (weak) IBOutlet OPPlayerView *playerView;
@property (weak) IBOutlet NSMenu *contextMenu;

-initWithItemViewController:(OPPItemViewController*)itemViewController;

- (IBAction)deleteItem:(id)sender;

-(BOOL)isPhoto;

-(BOOL)isVideo;

-(void)removedView;

@end
