//
//  OPNavigationBar.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPNavigationController.h"

extern NSString *const OPNavigationTitleFilterDidChange;

typedef enum {
    OPNavigationTitleFilterAlbums = 0,
    OPNavigationTitleFilterDevices = 1,
} OPNavigationTitleFilter;

@interface OPNavigationTitle : NSView<NSMenuDelegate> {
    IBOutlet NSTextField *_viewLabel;
    IBOutlet OPNavigationController *_navigationController;
}

@property (strong) IBOutlet NSButton *backButton;
@property (strong) IBOutlet NSSegmentedControl *cameraButton;
@property (strong) IBOutlet NSButton *shareWithButton;

- (void)updateTitle:(NSString*)label;

- (IBAction)goBack:(id)sender;
- (IBAction)cameraButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;

@end
