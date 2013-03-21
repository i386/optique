//
//  OPAppDelegate.m
//  Optique
//
//  Created by James Dumay on 19/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAppDelegate.h"

#import "OPPhotoAlbum.h"

@implementation OPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _window.titleBarHeight = 36.0;
    [_window.titleBarView addSubview:_toolbarView];
    
    NSRect buttonFrame = NSMakeRect(_toolbarView.frame.size.width, _toolbarView.frame.size.height, _toolbarView.frame.size.width, _toolbarView.frame.size.height);
    
    [_toolbarView setFrame:buttonFrame];
    
    NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    NSURL *picturesURL = [[[NSFileManager defaultManager] URLsForDirectory:NSPicturesDirectory inDomains:NSUserDomainMask] lastObject];
    
    _photoManager = [[OPPhotoManager alloc] initWithPath:picturesURL];
    
    for (OPPhotoAlbum *album in _photoManager.allAlbums)
    {
        NSLog(@"Album name: %@", album.name);
    }
}

@end
