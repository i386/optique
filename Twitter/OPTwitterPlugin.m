//
//  OPTwitterPlugin.m
//  Optique
//
//  Created by James Dumay on 7/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPTwitterPlugin.h"

@implementation OPTwitterPlugin

-(void)collectionManager:(XPCollectionManager *)collectionManager itemCollectionViewController:(id<XPItemCollectionViewController>)controller
{
    NSSharingService * service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    
    XPMenuItem *menuItem = [[XPMenuItem alloc] initWithTitle:service.title keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        id<XPItemCollection> collection = controller.visibleCollection;
        
        NSIndexSet *indexes = [controller selectedItems];
        
        NSMutableArray *items = [NSMutableArray array];
        for (id<XPItem> item in [collection itemsAtIndexes:indexes])
        {
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:item.url];
            [items addObject:image];
        }
        
        [service performWithItems:items];
    }];
    
    menuItem.image = service.image;
    
    [[controller sharingMenuItems] addObject:menuItem];
}

-(void)collectionManager:(XPCollectionManager *)collectionManager itemController:(id<XPItemController>)controller
{
    NSSharingService * service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    
    XPMenuItem *menuItem = [[XPMenuItem alloc] initWithTitle:service.title keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        id<XPItem> item = controller.item;
        
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:item.url];
        [service performWithItems:@[image]];
    }];
    
    menuItem.image = service.image;
    
    [[controller sharingMenuItems] addObject:menuItem];
}

@end
