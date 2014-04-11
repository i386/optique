//
//  XPItemsEnumerator.h
//  Optique
//
//  Created by James Dumay on 11/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPItemCollection.h"

@interface XPItemsEnumerator : NSEnumerator

-initWithCollections:(NSArray*)collections;

-(id<XPItem>)nextObject;

@end
