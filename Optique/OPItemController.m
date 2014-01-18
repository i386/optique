//
//  OPPhotoController.m
//  Optique
//
//  Created by James Dumay on 15/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPItemController.h"
#import "OPPItemViewController.h"

@interface OPItemController ()
@property (weak) OPPItemViewController *itemViewController;
@property (strong) NSMutableArray *sharingMenuItems;
@end

@implementation OPItemController

-(id)initWithItemViewController:(OPPItemViewController *)itemViewController
{
    self = [super initWithNibName:@"OPItemController" bundle:nil];
    if (self) {
        _itemViewController = itemViewController;
    }
    return self;
}

-(id<XPItem>)item
{
    return _itemViewController.item;
}

-(NSWindow *)window
{
    return self.view.window;
}

-(void)deleteSelected
{
    [_itemViewController deleteItem];
}

- (IBAction)deleteItem:(id)sender
{
    [_itemViewController deleteItem];
}

-(void)awakeFromNib
{
    _imageView.representedObject = _itemViewController.item;
    [XPExposureService collectionManager:_itemViewController.collection.collectionManager itemController:self];
}

-(BOOL)shareableItemsSelected
{
    return YES;
}

@end
