//
//  OPRenameAlbumWindowController.h
//  Optique
//
//  Created by James Dumay on 28/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OPRenameAlbumWindowController : NSWindowController

@property (strong, readonly) XPPhotoManager *photoManager;
@property (strong, readonly) id<XPPhotoCollection> collection;
@property (strong, readonly) NSViewController *viewController;

-initWithPhotoManager:(XPPhotoManager*)photoManager collection:(id<XPPhotoCollection>)collection parentController:(NSViewController*)viewController;

@end
