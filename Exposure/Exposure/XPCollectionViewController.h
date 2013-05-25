//
//  XPAlbumViewController.h
//  Exposure
//
//  Created by James Dumay on 6/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPController.h"

@protocol XPCollectionViewController <NSObject, XPController>

-(NSMenu*)contextMenu;

-(NSIndexSet*)selectedItems;

@end
