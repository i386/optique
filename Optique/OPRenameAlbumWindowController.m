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

-(id)initWithCollectionManager:(XPCollectionManager *)collectionManager collection:(id<XPItemCollection>)collection parentController:(NSViewController *)viewController
{
    self = [super initWithWindowNibName:@"OPRenameAlbumWindowController"];
    if (self)
    {
        _collectionManager = collectionManager;
        _collection = collection;
        _viewController = viewController;
    }
    return self;
}

-(void)awakeFromNib
{
    _nameTextField.stringValue = _collection.title;
    [_nameTextField selectText:self];
}

- (IBAction)rename:(id)sender
{
    NSString *value = _nameTextField.stringValue;
    if (![value isEqualToString:@""])
    {
        NSError *error;
        [_collectionManager renameAlbum:_collection to:value error:&error];
        
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
