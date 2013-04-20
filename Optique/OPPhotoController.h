//
//  OPPhotoController.h
//  Optique
//
//  Created by James Dumay on 15/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OPPhotoViewController;

@interface OPPhotoController : NSViewController

@property (strong) IBOutlet NSImageView *imageView;
@property (strong) IBOutlet NSMenu *contextMenu;

-initWithPhotoViewController:(OPPhotoViewController*)photoViewController;

-(void)setFilter:(CIFilter*)filter;

- (IBAction)revealInFinder:(id)sender;

- (IBAction)deletePhoto:(id)sender;

@end
