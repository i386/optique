//
//  OPAppDelegate.m
//  Optique
//
//  Created by James Dumay on 19/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAppDelegate.h"

#import "OPPhotoAlbum.h"
#import "OPPhoto.h"
#import "OPImageCache.h"

@implementation OPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _cameraService = [[OPCameraService alloc] init];
    
    NSURL *url = [[_userDefaultsController defaults] URLForKey:@"url"];
    if (!url)
    {
        url = [[[NSFileManager defaultManager] URLsForDirectory:NSPicturesDirectory inDomains:NSUserDomainMask] lastObject];
    }
    
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
    _mainWindowController = [[OPMainWindowController alloc] initWithPhotoManager:_photoManager];
    [_mainWindowController.window makeKeyAndOrderFront:self];
    
    _albumScaner = [[OPAlbumScanner alloc] initWithPhotoManager:_photoManager];
    [_albumScaner scanAtURL:url];
    
    [_cameraService restart];
}

@end
