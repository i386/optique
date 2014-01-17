//
//  XPPhotoCollectionViewController.h
//  Exposure
//
//  Created by James Dumay on 6/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPController.h"
#import "XPSharingService.h"
#import "XPItemCollection.h"

@protocol XPItemCollectionViewController <NSObject, XPController, XPSharingService>

-(NSMenu*)contextMenu;

-(id<XPItemCollection>)visibleCollection;

-(NSIndexSet*)selectedItems;

@end
