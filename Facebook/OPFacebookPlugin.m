//
//  OPFacebookPlugin.m
//  Optique
//
//  Created by James Dumay on 7/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFacebookPlugin.h"

@implementation OPFacebookPlugin

-(void)photoManager:(XPPhotoManager *)photoManager photoCollectionViewController:(id<XPPhotoCollectionViewController>)controller
{
    NSSharingService * service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnFacebook];
    
    XPMenuItem *item = [[XPMenuItem alloc] initWithTitle:service.title keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        id<XPPhotoCollection> collection = controller.visibleCollection;
        
        NSIndexSet *indexes = [controller selectedItems];
        
        NSMutableArray *photos = [NSMutableArray array];
        for (id<XPPhoto> photo in [collection photosForIndexSet:indexes])
        {
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:photo.url];
            [photos addObject:image];
        }
        
        [service performWithItems:photos];
    }];
    
    item.image = service.image;
    [[controller sharingMenuItems] addObject:item];
}

-(void)photoManager:(XPPhotoManager *)photoManager photoController:(id<XPPhotoController>)controller
{
    NSSharingService * service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnFacebook];
    
    XPMenuItem *item = [[XPMenuItem alloc] initWithTitle:service.title keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        id<XPPhoto> photo = controller.visiblePhoto;
        
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:photo.url];
        [service performWithItems:@[image]];
        
    }];
    
    item.image = service.image;
    [[controller sharingMenuItems] addObject:item];
}

@end
