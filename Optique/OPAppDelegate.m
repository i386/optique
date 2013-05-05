//
//  OPAppDelegate.m
//  Optique
//
//  Created by James Dumay on 19/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAppDelegate.h"

#import <HockeySDK/BITHockeyManager.h>

#import "OPPhotoAlbum.h"
#import "OPPhoto.h"
#import "OPImageCache.h"

@implementation OPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"52814104cfd270328887432ee78c4dd1" companyName:@"Whimsy" crashReportManagerDelegate:self];
    [[BITHockeyManager sharedHockeyManager] setExceptionInterceptionEnabled:YES];
    [[BITHockeyManager sharedHockeyManager] startManager];
}

-(void)showMainApplicationWindow
{
    NSURL *url = [[_userDefaultsController defaults] URLForKey:@"url"];
    if (!url)
    {
        url = [[[NSFileManager defaultManager] URLsForDirectory:NSPicturesDirectory inDomains:NSUserDomainMask] lastObject];
    }
    
    _cameraService = [[OPCameraService alloc] init];
    
    [self picturesAtDirectory:url];
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
            [_albumScaner setStopScan:YES];
            [[OPImageCache sharedPreviewCache] clearCache];
            [self picturesAtDirectory:openPanel.URL];
        }
    }];
}

- (IBAction)newAlbum:(id)sender
{
    [_mainWindowController showNewAlbumSheet];
}

-(void)picturesAtDirectory:(NSURL*)url
{
    [[_userDefaultsController defaults] setURL:url forKey:@"url"];
    [_userDefaultsController save:self];
    
    if (_mainWindowController)
    {
        [_mainWindowController close];
    }
    
    _photoManager = [[OPPhotoManager alloc] initWithPath:url];
    
    [_cameraService setPhotoManager:_photoManager];
    if (!_cameraService.deviceBrowser.isBrowsing)
    {
        [_cameraService start];
    }
    else
    {
        [_cameraService stop];
        [_cameraService start];
    }
    
    _mainWindowController = [[OPMainWindowController alloc] initWithPhotoManager:_photoManager];
    [_mainWindowController.window makeKeyAndOrderFront:self];
    
    _albumScaner = [[OPAlbumScanner alloc] initWithPhotoManager:_photoManager cameraService:_cameraService];
    [_albumScaner scanAtURL:url];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    //Remove all the caches if any exist
    if (_cameraService)
    {
        [_cameraService removeCaches];
    }
}

@end
