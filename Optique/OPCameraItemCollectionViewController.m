//
//  OPCameraPhotoCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 20/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraItemCollectionViewController.h"
#import "OPImportItemsWindowController.h"
#import "OPItemPhotoGridViewCell.h"

@interface OPCameraItemCollectionViewController ()

@property (strong) OPImportItemsWindowController *importItemsWindowController;

@end

@implementation OPCameraItemCollectionViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.gridView.isSelectionSticky = YES;
    self.primaryActionButton.title = @"Import";
    self.secondaryActionButton.title = @"Clear selection";
}

-(void)primaryActionActivated:(id)sender
{
    _importItemsWindowController = [[OPImportItemsWindowController alloc] initWithItems:[self.collection itemsAtIndexes:[self selectedItems]] collectionManager:self.collectionManager whenCompleted:^(NSError *error) {
        [self.gridView deselectAll:self];
    }];
    
    [NSApp beginSheet:_importItemsWindowController.window modalForWindow:self.view.window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(OPItemGridViewCell *)createItemGridViewCell:(id<XPItem>)item
{
    return [[OPItemPhotoGridViewCell alloc] init];
}

@end
