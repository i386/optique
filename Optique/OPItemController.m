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

-(BOOL)isPhoto
{
    return [_itemViewController.item type] == XPItemTypePhoto;
}

-(BOOL)isVideo
{
    return [_itemViewController.item type] == XPItemTypeVideo;
}

-(void)awakeFromNib
{
    id<XPItem> item = _itemViewController.item;

    _imageView.representedObject = item;
    _playerView.representedObject = item;
    _playerView.actionPopUpButtonMenu = _contextMenu;
    
    [XPExposureService collectionManager:_itemViewController.collection.collectionManager itemController:self];
}

-(void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    _playerView.representedObject = representedObject;
    _imageView.representedObject = representedObject;
}

-(BOOL)shareableItemsSelected
{
    return YES;
}

@end
