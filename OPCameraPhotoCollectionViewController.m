//
//  OPCameraPhotoCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 20/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraPhotoCollectionViewController.h"
#import "OPImportPhotosWindowController.h"
#import "OPCameraPhotoGridViewCell.h"

@interface OPCameraPhotoCollectionViewController ()

@property (strong) OPImportPhotosWindowController *importPhotosWindowController;

@end

@implementation OPCameraPhotoCollectionViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.gridView.isSelectionSticky = YES;
    self.primaryActionButton.title = @"Import";
    self.secondaryActionButton.title = @"Clear selection";
}

-(void)primaryActionActivated:(id)sender
{
    _importPhotosWindowController = [[OPImportPhotosWindowController alloc] initWithPhotos:[self.collection photosForIndexSet:[self selectedItems]] photoManager:self.photoManager whenCompleted:^(NSError *error) {
        [self.gridView deselectAll:self];
    }];
    
    [NSApp beginSheet:_importPhotosWindowController.window modalForWindow:self.view.window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(OPPhotoGridViewCell *)createPhotoGridViewCell
{
    return [[OPCameraPhotoGridViewCell alloc] init];
}

@end
