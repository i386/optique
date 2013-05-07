//
//  OPTwitterPlugin.m
//  Optique
//
//  Created by James Dumay on 7/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPTwitterPlugin.h"

@implementation OPTwitterPlugin

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
    
    [[controller contextMenu] addItem:item];
}

@end
