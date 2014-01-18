//
//  OPNewAlbumSheetController.m
//  Optique
//
//  Created by James Dumay on 10/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNewAlbumSheetController.h"
#import "OPItemCollectionViewController.h"

@interface OPNewAlbumSheetController ()

@end

@implementation OPNewAlbumSheetController

-(id)initWithCollectionManager:(XPCollectionManager *)collectionManager navigationController:(OPNavigationController *)navigationController
{
    self = [super initWithWindowNibName:@"OPNewAlbumSheetController"];
    if (self)
    {
        _collectionManager = collectionManager;
        _navigationController = navigationController;
    }
    return self;
}

- (IBAction)createAlbum:(id)sender
{
    NSString *albumName = _albumNameTextField.stringValue;
    
    NSError *error;
    
    id<XPItemCollection> album = [_collectionManager newAlbumWithName:albumName error:&error];
    if (album)
    {
        [self.window orderOut:nil];
        [NSApp endSheet:self.window];
        
        [_albumNameTextField setStringValue:@""];
        [_navigationController popToRootViewController];
        
        OPItemCollectionViewController *itemCollectionController = [[OPItemCollectionViewController alloc] initWithIemCollection:album collectionManager:_collectionManager];
        [_navigationController pushViewController:itemCollectionController];
    }
    else
    {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
    }
}

- (IBAction)cancel:(id)sender
{
    [self.window orderOut:nil];
    [_albumNameTextField setStringValue:@""];
    [NSApp endSheet:self.window];
}

@end
