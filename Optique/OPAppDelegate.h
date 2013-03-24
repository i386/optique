//
//  OPAppDelegate.h
//  Optique
//
//  Created by James Dumay on 19/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <INAppStoreWindow/INAppStoreWindow.h>

#import "OPPhotoManager.h"
#import "OPAlbumViewController.h"

@interface OPAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
    OPPhotoManager *_photoManager;
    OPAlbumViewController *_albumViewController;
}

@property (assign) IBOutlet INAppStoreWindow *window;
@property (weak) IBOutlet NSView *toolbarView;

@end
