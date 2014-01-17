//
//  OPRenameAlbumWindowController.h
//  Optique
//
//  Created by James Dumay on 28/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OPRenameAlbumWindowController : NSWindowController

@property (strong, readonly) XPCollectionManager *collectionManager;
@property (strong, readonly) id<XPItemCollection> collection;
@property (strong, readonly) NSViewController *viewController;

-initWithCollectionManager:(XPCollectionManager*)collectionManager collection:(id<XPItemCollection>)collection parentController:(NSViewController*)viewController;

@end
