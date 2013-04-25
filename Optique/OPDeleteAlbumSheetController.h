//
//  OPDeleteAlbumSheetController.h
//  Optique
//
//  Created by James Dumay on 10/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPPhotoAlbum.h"
#import "OPPhotoManager.h"

@interface OPDeleteAlbumSheetController : NSWindowController <NSFileManagerDelegate>

@property (readonly, strong) NSArray *albums;
@property (readonly, weak) OPPhotoManager *photoManager;
@property (strong) IBOutlet NSTextField *labelTextField;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;

-initWithPhotoAlbums:(NSArray*)albums photoManager:(OPPhotoManager*)photoManager;

-(void)startAlbumDeletion;

@end