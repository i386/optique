//
//  OPDeleteAlbumSheetController.h
//  Optique
//
//  Created by James Dumay on 10/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OPDeleteAlbumSheetController : NSWindowController <NSFileManagerDelegate>

@property (readonly, strong) NSArray *albums;
@property (readonly, weak) XPCollectionManager *collectionManager;
@property (weak) IBOutlet NSTextField *labelTextField;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak, readonly) NSViewController *viewController;

-initWithCollections:(NSArray*)albums collectionManager:(XPCollectionManager*)collectionManager parentController:(NSViewController*)viewController;

-(void)startAlbumDeletion;

@end
