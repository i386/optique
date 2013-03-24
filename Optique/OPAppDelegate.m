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
    _window.titleBarHeight = 36.0;
    [_window.titleBarView addSubview:_toolbarView];
    
    NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    NSURL *picturesURL = [[[NSFileManager defaultManager] URLsForDirectory:NSPicturesDirectory inDomains:NSUserDomainMask] lastObject];
    
    _photoManager = [[OPPhotoManager alloc] initWithPath:picturesURL];
    
    _albumViewController = [[OPAlbumViewController alloc] initWithPhotoManager:_photoManager];
    
    [_window.contentView addSubview:_albumViewController.view];
}

@end
