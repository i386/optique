//
//  OPRenameAlbumWindowController.m
//  Optique
//
//  Created by James Dumay on 28/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPRenameAlbumWindowController.h"

@interface OPRenameAlbumWindowController ()

@property (weak) IBOutlet NSTextField *nameTextField;

@end

@implementation OPRenameAlbumWindowController

-(id)initWithPhotoManager:(XPPhotoManager *)photoManager collection:(id<XPPhotoCollection>)collection parentController:(NSViewController *)viewController
{
    self = [super initWithWindowNibName:@"OPRenameAlbumWindowController"];
    if (self)
    {
        _photoManager = photoManager;
        _collection = collection;
        _viewController = viewController;
    }
    return self;
}

- (IBAction)rename:(id)sender
{
    NSString *value = _nameTextField.stringValue;
    if (![value isEqualToString:@""])
    {
        NSError *error;
        [_photoManager renameAlbum:_collection to:value error:&error];
        
        [NSApp endSheet:self.window];
        [self.window close];
        
        if (error)
        {
            NSAlert *alert = [NSAlert alertWithError:error];
            
            [alert beginSheetModalForWindow:_viewController.view.window completionHandler:^(NSModalResponse returnCode) {
                
            }];
        }
    }
}

- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:self.window];
    [self.window close];
}

@end
