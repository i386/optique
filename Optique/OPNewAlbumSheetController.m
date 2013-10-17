//
//  OPNewAlbumSheetController.m
//  Optique
//
//  Created by James Dumay on 10/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNewAlbumSheetController.h"
#import "OPPhotoCollectionViewController.h"

@interface OPNewAlbumSheetController ()

@end

@implementation OPNewAlbumSheetController

-(id)initWithPhotoManager:(XPPhotoManager *)photoManager navigationController:(OPNavigationController *)navigationController
{
    self = [super initWithWindowNibName:@"OPNewAlbumSheetController"];
    if (self)
    {
        _photoManager = photoManager;
        _navigationController = navigationController;
    }
    return self;
}

- (IBAction)createAlbum:(id)sender
{
    NSString *albumName = _albumNameTextField.stringValue;
    
    NSError *error;
    
    id<XPPhotoCollection> album = [_photoManager newAlbumWithName:albumName error:&error];
    if (album)
    {
        [self.window orderOut:nil];
        [NSApp endSheet:self.window];
        
        [_albumNameTextField setStringValue:@""];
        [_navigationController popToRootViewController];
        
        OPPhotoCollectionViewController *photoCollectionController = [[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:album photoManager:_photoManager];
        [_navigationController pushViewController:photoCollectionController];
    }
    else
    {
        NSString *message = error ? error.userInfo[@"message"] : @"Could not create album";
        NSString *longMessage = error ? error.userInfo[@"longmessage"] : @"An error prevented the album from being created.";
        
        NSBeginAlertSheet(message, @"OK", nil, nil, self.window, self, nil, nil, nil, longMessage, nil);
    }
}

- (IBAction)cancel:(id)sender
{
    [self.window orderOut:nil];
    [_albumNameTextField setStringValue:@""];
    [NSApp endSheet:self.window];
}

@end
