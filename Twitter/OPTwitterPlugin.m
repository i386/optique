//
//  OPTwitterPlugin.m
//  Optique
//
//  Created by James Dumay on 7/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPTwitterPlugin.h"

@implementation OPTwitterPlugin

-(void)photoManager:(XPPhotoManager *)photoManager photoCollectionViewController:(id<XPPhotoCollectionViewController>)controller
{
    NSSharingService * service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    
    XPMenuItem *item = [[XPMenuItem alloc] initWithTitle:service.title keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        id<XPPhotoCollection> collection = controller.visibleCollection;
        
        NSIndexSet *indexes = [controller selectedItems];
        
        NSMutableArray *photos = [NSMutableArray array];
        for (id<XPPhoto> photo in [collection photosForIndexSet:indexes])
        {
            NSConditionLock *condition = [photo resolveURL:^(NSURL *suppliedUrl) {
                NSImage *image = [[NSImage alloc] initWithContentsOfURL:suppliedUrl];
                [photos addObject:image];
            }];
            
            [condition lock];
            [condition unlockWithCondition:1];
        }
        
        [service performWithItems:photos];
    }];
    
    item.image = service.image;
    
    [[controller sharingMenuItems] addObject:item];
}

-(void)photoManager:(XPPhotoManager *)photoManager photoController:(id<XPPhotoController>)controller
{
    NSSharingService * service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    
    XPMenuItem *item = [[XPMenuItem alloc] initWithTitle:service.title keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        id<XPPhoto> photo = controller.visiblePhoto;
        
        [photo imageWithCompletionBlock:^(NSImage *image) {
            [service performWithItems:@[image]];
        }];
        
    }];
    
    item.image = service.image;
    
    [[controller sharingMenuItems] addObject:item];
}

@end
