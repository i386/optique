//
//  OPDeleteAlbumSheetController.m
//  Optique
//
//  Created by James Dumay on 10/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPDeleteAlbumSheetController.h"

@interface OPDeleteAlbumSheetController ()

@end

@implementation OPDeleteAlbumSheetController

-(id)initWithPhotoAlbum:(OPPhotoAlbum *)photoAlbum photoManager:(OPPhotoManager *)photoManager
{
    self = [super initWithWindowNibName:@"OPDeleteAlbumSheetController"];
    if (self) {
        _photoAlbum = photoAlbum;
        _photoManager = photoManager;
    }
    
    return self;
}

-(void)windowDidLoad
{
    [super windowDidLoad];
    [_progressIndicator startAnimation:self];
    [_labelTextField setStringValue:[NSString stringWithFormat:@"Deleting album '%@'...", _photoAlbum.title]];
}

-(void)startAlbumDeletion
{
    [self performBlockInBackground:^{
        [_photoManager deleteAlbum:_photoAlbum];
        [self performBlockOnMainThread:^{
            [NSApp endSheet:self.window];
            [self.window close];
        }];
    }];
}

- (void)sheetDidEndShouldClose:(NSWindow *)sheet
                    returnCode:(NSInteger)returnCode
                   contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        NSLog(@"delete");
    }
}

@end
