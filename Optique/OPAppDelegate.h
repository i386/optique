//
//  OPAppDelegate.h
//  Optique
//
//  Created by James Dumay on 19/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>
#import <HockeySDK/HockeySDK.h>

#import "OPCameraService.h"
#import "OPMainWindowController.h"
#import "OPPreferencesWindowController.h"

@interface OPAppDelegate : NSObject <NSApplicationDelegate, BITHockeyManagerDelegate>

@property (readonly, strong) XPCollectionManager *collectionManager;
@property (readonly, strong) OPMainWindowController *mainWindowController;
@property (strong) IBOutlet NSUserDefaultsController *userDefaultsController;
@property (strong) OPPreferencesWindowController *preferencesWindowController;

@property (weak) IBOutlet NSMenuItem *debugMenu;
@property (weak) IBOutlet NSMenuItem *fullscreenMenuItem;
@property (weak) IBOutlet NSMenuItem *exitFullscreenMenuItem;
@property (weak) IBOutlet SUUpdater *updater;

- (IBAction)openDirectory:(id)sender;
- (IBAction)newAlbum:(id)sender;
- (IBAction)toggleFullScreen:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)findAlbum:(id)sender;

@end
