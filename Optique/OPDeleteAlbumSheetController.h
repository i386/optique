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
@property (readonly, weak) XPPhotoManager *photoManager;
@property (strong) IBOutlet NSTextField *labelTextField;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong, readonly) NSViewController *viewController;

-initWithPhotoAlbums:(NSArray*)albums photoManager:(XPPhotoManager*)photoManager parentController:(NSViewController*)viewController;

-(void)startAlbumDeletion;

@end
