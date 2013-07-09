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

    //Application is now ready to accept plugin loading
    [OPExposureService loadPlugins:aNotification.userInfo];
    
    [self picturesAtDirectory:url];
    
#if DEBUG
    [_debugMenu setHidden:NO];
    [self setupDebugMenu];
#endif
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
    [OPExposureService photoManagerWasCreated:_photoManager];
    
    _mainWindowController = [[OPMainWindowController alloc] initWithPhotoManager:_photoManager];
    [_mainWindowController.window makeKeyAndOrderFront:self];
    
    _albumScaner = [[OPAlbumScanner alloc] initWithPhotoManager:_photoManager];
    [_albumScaner scanAtURL:url];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    [OPExposureService unloadPlugins:notification.userInfo];
}

-(NSURL*)resolvePicturesDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSPicturesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)setupDebugMenu
{
    NSArray *defaultItems = [[[_debugMenu submenu] itemArray] copy];
    [_debugMenu.submenu removeAllItems];
    
    [[OPExposureService debugMenuItems] each:^(id sender) {
        [_debugMenu.submenu addItem:sender];
    }];
    
    [defaultItems each:^(id sender) {
        [_debugMenu.submenu addItem:sender];
    }];
}

- (IBAction)debugClearCache:(id)sender
{
    [[OPImageCache sharedPreviewCache] clearCache];
    [self picturesAtDirectory:_photoManager.path];
}

@end
