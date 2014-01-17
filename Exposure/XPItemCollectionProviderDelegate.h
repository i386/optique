//
//  OPPhotoCollectionDelegate.h
//  Optique
//
//  Created by James Dumay on 5/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPItemCollection.h"

@protocol XPItemCollectionProviderDelegate <NSObject>

-(void)didAddItemCollection:(id<XPItemCollection>)itemCollection;

-(void)didRemoveItemCollection:(id<XPItemCollection>)itemCollection;

@end
