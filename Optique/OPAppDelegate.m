//
//  OPAppDelegate.m
//  Optique
//
//  Created by James Dumay on 19/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAppDelegate.h"
#import "OPImageCache.h"
#import "OPExposureService.h"

@implementation OPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
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
    [_mainWindowController showNewAlbumSheet];
}

-(void)picturesAtDirectory:(NSURL*)url
{
    [_userDefaultsController save:self];
    
    if (_mainWindowController)
    {
        [_mainWindowController close];
    }
    
    _photoManager = [[XPPhotoManager alloc] initWithPath:url];
    
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

-(NSURL*)resolvePicturesDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSPicturesDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
