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

@implementation OPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    NSURL *picturesURL = [[[NSFileManager defaultManager] URLsForDirectory:NSPicturesDirectory inDomains:NSUserDomainMask] lastObject];
    
    _photoManager = [[OPPhotoManager alloc] initWithPath:picturesURL];
    _mainWindowController = [[OPMainWindowController alloc] init];
    _mainWindowController.photoManager = _photoManager;
    [_mainWindowController.window makeKeyAndOrderFront:self];
}

@end
