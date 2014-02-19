//
//  OPAppDelegate.m
//  Optique
//
//  Created by James Dumay on 19/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAppDelegate.h"
#import "OPItemPreviewManager.h"
#import <Exposure/Exposure.h>
#import "NSWindow+FullScreen.h"
#import <HockeySDK/BITHockeyManager.h>
#import "OPNewAlbumPanelViewController.h"

@implementation OPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self registerDefaults];
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"52814104cfd270328887432ee78c4dd1" companyName:@"Whimsy Apps" delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
}

-(void)showMainApplicationWindowForCrashManager:(BITCrashManager *)crashManager
{
    _preferencesWindowController = [[OPPreferencesWindowController alloc] init];
    
    NSData *bookmarkData = [[_userDefaultsController defaults] objectForKey:@"url"];
    
    NSURL *url;
    if (bookmarkData)
    {
        BOOL isStale;
        NSError *error;
        url = [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:&isStale error:nil];
        
        if (error || isStale)
        {
            url = [self resolvePicturesDirectoryURL];
        }
        else
        {
            [url startAccessingSecurityScopedResource];
        }
    }
    else
    {
        url = [self resolvePicturesDirectoryURL];
    }
    
    //Application is now ready to accept plugin loading
    [XPExposureService loadPlugins:@{}];
    
    [self picturesAtDirectory:url];
    
#if DEBUG
    [_debugMenu setHidden:NO];
    [self setupDebugMenu];
#endif
    
//    if (![[_userDefaultsController defaults] boolForKey:@"shown-newsletter"])
//    {
//        _newsletterWindowController = [[OPNewsletterWindowController alloc] init];
//        [_mainWindowController.window beginSheet:_newsletterWindowController.window completionHandler:^(NSModalResponse returnCode) {
//           //Do nada
//        }];
//    }
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)openDirectory:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanCreateDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    
    [openPanel beginSheetModalForWindow:_mainWindowController.window completionHandler:^(NSInteger result)
    {
        if (result == NSFileHandlingPanelOKButton)
        {
            [[OPItemPreviewManager defaultManager] clearCache];
            
            NSError *error;
            NSData *data = [openPanel.URL bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
            
            if (error)
            {
                NSLog(@"Error setting bookmark %@", error.userInfo);
            }
            else
            {
                [[_userDefaultsController defaults] setObject:data forKey:@"url"];
            }
            
            [self picturesAtDirectory:openPanel.URL];
        }
    }];
}

- (IBAction)newAlbum:(id)sender
{
    OPNewAlbumPanelViewController *controller = [[OPNewAlbumPanelViewController alloc] initWithCollectionManager:_collectionManager sidebarController:_mainWindowController];
    [_mainWindowController showSidebarWithViewController:controller];
}

-(void)picturesAtDirectory:(NSURL*)url
{
    [_userDefaultsController save:self];
    
    if (_mainWindowController)
    {
        [_mainWindowController close];
    }
    
    _collectionManager = [[XPCollectionManager alloc] initWithPath:url];
    [XPExposureService collectionManagerWasCreated:_collectionManager];
    
    if (_mainWindowController)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEnterFullScreenNotification object:_mainWindowController.window];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidExitFullScreenNotification object:_mainWindowController.window];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterFullscreen:) name:NSWindowDidEnterFullScreenNotification object:_mainWindowController.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didExitFullscreen:) name:NSWindowDidExitFullScreenNotification object:_mainWindowController.window];
    
    _mainWindowController = [[OPMainWindowController alloc] initWithCollectionManager:_collectionManager];
    [_mainWindowController.window makeKeyAndOrderFront:self];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    [XPExposureService unloadPlugins:notification.userInfo];
}

-(NSURL*)resolvePicturesDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSPicturesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)registerDefaults
{
    NSDictionary *defaultPreferences = @{@"ShowCameraContentsOnConnect": [NSNumber numberWithBool:YES],
                                         @"ItemSize": [NSNumber numberWithInteger:50]};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
}

- (void)setupDebugMenu
{
    NSArray *defaultItems = [[[_debugMenu submenu] itemArray] copy];
    [_debugMenu.submenu removeAllItems];
    
    [[XPExposureService debugMenuItems] bk_each:^(id sender) {
        [_debugMenu.submenu addItem:sender];
    }];
    
    [defaultItems bk_each:^(id sender) {
        [_debugMenu.submenu addItem:sender];
    }];
}

- (IBAction)debugClearCache:(id)sender
{
    [[OPItemPreviewManager defaultManager] clearCache];
    [self picturesAtDirectory:_collectionManager.path];
}

- (IBAction)showAlbums:(id)sender
{
    [_mainWindowController showAlbums];
}

- (IBAction)showCameras:(id)sender
{
    [_mainWindowController showCameras];
}

- (IBAction)goBack:(id)sender
{
    [_mainWindowController goBack];
}

- (IBAction)showHelp:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://whimsyapps.uservoice.com/forums/202362-general"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)followOnTwitter:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://twitter.com/whimsyapps"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)toggleFullScreen:(id)sender
{
    [_mainWindowController.window toggleFullScreen:sender];
}

- (IBAction)openPreferences:(id)sender
{
    [_preferencesWindowController.window makeKeyAndOrderFront:sender];
}

- (IBAction)findAlbum:(id)sender
{
    [_mainWindowController.toolbarViewController.searchFilter becomeFirstResponder];
}

-(void)didEnterFullscreen:(NSNotification*)notification
{
    [_fullscreenMenuItem setHidden:YES];
    [_exitFullscreenMenuItem setHidden:NO];
}

-(void)didExitFullscreen:(NSNotification*)notification
{
    [_fullscreenMenuItem setHidden:NO];
    [_exitFullscreenMenuItem setHidden:YES];
}

@end
