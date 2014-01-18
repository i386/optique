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

-(id)initWithCollections:(NSArray *)albums collectionManager:(XPCollectionManager *)collectionManager parentController:(NSViewController *)viewController
{
    self = [super initWithWindowNibName:@"OPDeleteAlbumSheetController"];
    if (self) {
        _albums = albums;
        _collectionManager = collectionManager;
        _viewController = viewController;
    }
    
    return self;
}

-(void)windowDidLoad
{
    [super windowDidLoad];
    [_progressIndicator startAnimation:self];
    
    NSString *message;
    if (_albums.count > 1)
    {
        message = [NSString stringWithFormat:@"Deleting %lu albums...", _albums.count];
    }
    else
    {
        id<XPItemCollection> album = [_albums lastObject];
        message = [NSString stringWithFormat:@"Deleting album '%@'...", album.title];
    }
    
    [_labelTextField setStringValue:message];
}

-(void)startAlbumDeletion
{
    [self performBlockInBackground:^{
        [_albums each:^(id sender) {
            NSError *error;
            [_collectionManager deleteAlbum:sender error:&error];
            
            if (error)
            {
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert beginSheetModalForWindow:_viewController.view.window completionHandler:^(NSModalResponse returnCode) {
                    
                }];
            }
        }];
        
        [self performBlockOnMainThread:^{
            [NSApp endSheet:self.window];
            [self.window close];
            _albums = nil; //Avoid leak
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
