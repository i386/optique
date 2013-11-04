//
//  OPAppDelegate.h
//  Optique
//
//  Created by James Dumay on 19/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <INAppStoreWindow/INAppStoreWindow.h>
#import <MASPreferences/MASPreferencesWindowController.h>
#import <Sparkle/Sparkle.h>

#import "OPCameraService.h"
#import "OPMainWindowController.h"

@interface OPAppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) XPPhotoManager *photoManager;
@property (readonly, strong) OPMainWindowController *mainWindowController;
@property (strong) IBOutlet NSUserDefaultsController *userDefaultsController;
@property (strong) MASPreferencesWindowController *preferencesWindowController;

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
