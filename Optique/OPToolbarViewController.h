//
//  OPToolbarViewController.h
//  Optique
//
//  Created by James Dumay on 15/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPNavigationController.h"
#import "OPDropDownButton.h"

extern NSString *const OPApplicationModeDidChange;
extern NSString *const OPAlbumSearchFilterDidChange;


typedef enum {
    OPApplicationModeAlbum = 0,
    OPApplicationModeCamera = 1,
} OPApplicationMode;


@interface OPToolbarViewController : NSViewController<NSMenuDelegate>

@property (assign) OPApplicationMode filterMode;
@property (strong) IBOutlet OPDropDownButton *shareWithButton;
@property (strong) IBOutlet NSButton *switchViewButton;
@property (strong) IBOutlet NSSearchField *searchFilter;
@property (weak) OPNavigationController *navigationController;

- (IBAction)switchViewButtonPressed:(id)sender;

- (void)backMode;

- (void)albumMode;

- (void)cameraMode;

@end
