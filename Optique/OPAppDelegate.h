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
#import "OPAlbumScanner.h"
#import "OPMainWindowController.h"

@interface OPAppDelegate : NSObject <NSApplicationDelegate> {
    OPAlbumScanner *_albumScaner;
    OPPhotoManager *_photoManager;
    OPMainWindowController *_mainWindowController;
}

@end
