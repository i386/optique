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
    id<XPItem> item = _itemViewController.item;
    
    _imageView.representedObject = item;
    _playerView.representedObject = item;
    
    if ([item type] == XPItemTypePhoto)
    {
        [_imageView setHidden:NO];
    }
    else if ([item type] == XPItemTypeVideo)
    {
        [_playerView setHidden:NO];
    }
    else
    {
        NSLog(@"Cannot display item of type %@", [item class]);
    }
    
    [XPExposureService collectionManager:_itemViewController.collection.collectionManager itemController:self];
}

-(BOOL)shareableItemsSelected
{
    return YES;
}

@end
