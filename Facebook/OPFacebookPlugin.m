//
//  OPFacebookPlugin.m
//  Optique
//
//  Created by James Dumay on 7/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFacebookPlugin.h"

@implementation OPFacebookPlugin

-(void)collectionManager:(XPCollectionManager *)collectionManager itemCollectionViewController:(id<XPItemCollectionViewController>)controller
{
    NSSharingService * service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnFacebook];
    
    XPMenuItem *item = [[XPMenuItem alloc] initWithTitle:service.title keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
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
    
    item.image = service.image;
    [[controller sharingMenuItems] addObject:item];
}

-(void)collectionManager:(XPCollectionManager *)collectionManager itemController:(id<XPItemController>)controller
{
    NSSharingService * service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnFacebook];
    
    XPMenuItem *item = [[XPMenuItem alloc] initWithTitle:service.title keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        id<XPItem> item = controller.item;
        
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:item.url];
        [service performWithItems:@[image]];
        
    }];
    
    item.image = service.image;
    [[controller sharingMenuItems] addObject:item];
}

@end
