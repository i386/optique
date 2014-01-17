//
//  OPCameraPhotoCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 20/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraPhotoCollectionViewController.h"
#import "OPImportItemsWindowController.h"
#import "OPItemPhotoGridViewCell.h"

@interface OPCameraPhotoCollectionViewController ()

@property (strong) OPImportItemsWindowController *importPhotosWindowController;

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
    _importPhotosWindowController = [[OPImportItemsWindowController alloc] initWithItems:[self.collection itemsAtIndexes:[self selectedItems]] collectionManager:self.collectionManager whenCompleted:^(NSError *error) {
        [self.gridView deselectAll:self];
    }];
    
    [NSApp beginSheet:_importPhotosWindowController.window modalForWindow:self.view.window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(OPItemGridViewCell *)createPhotoGridViewCell
{
    return [[OPItemPhotoGridViewCell alloc] init];
}

@end
