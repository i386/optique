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
#import "OPNotificationSynchronizer.h"
#import "OPPeekButton.h"

extern NSString *const OPApplicationModeDidChange;
extern NSString *const OPAlbumSearchFilterDidChange;
extern NSString *const OPSharableSelectionChanged;


typedef enum {
    OPApplicationModeAlbum = 0,
    OPApplicationModeCamera = 1,
} OPApplicationMode;


@interface OPToolbarController : NSObject<NSMenuDelegate, NSToolbarDelegate>

@property (assign) OPApplicationMode filterMode;
@property (strong) IBOutlet OPDropDownButton *shareWithButton;
@property (strong) IBOutlet OPPeekButton *switchViewButton;
@property (strong) IBOutlet NSSearchField *searchFilter;
@property (weak, nonatomic) OPNavigationController *navigationController;
@property (weak) IBOutlet NSProgressIndicator *loadProgressIndicator;
@property (strong) OPNotificationSynchronizer *syncCollectionEvents;

- (IBAction)switchViewButtonPressed:(id)sender;

- (void)backMode;

- (void)albumMode;

- (void)cameraMode;

@end