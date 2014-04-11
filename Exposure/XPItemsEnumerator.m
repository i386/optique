//
//  XPItemsEnumerator.m
//  Optique
//
//  Created by James Dumay on 11/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "XPItemsEnumerator.h"

@interface XPItemsEnumerator()

@property (strong) NSArray *collections;
@property (strong) id<XPItemCollection> currentCollection;
@property (assign) NSUInteger collectionIndex;
@property (assign) NSUInteger itemIndex;

@end

@implementation XPItemsEnumerator

-(id)initWithCollections:(NSArray *)collections
{
    self = [super init];
    if (self)
    {
        _collections = collections;
        _currentCollection = [collections firstObject];
        _collectionIndex = 0;
        _itemIndex = 0;
    }
    return self;
}

-(id<XPItem>)nextObject
{
    if (!_currentCollection) return nil;
    
    id<XPItem> item = [[_currentCollection itemsAtIndexes:[NSIndexSet indexSetWithIndex:_itemIndex]] lastObject];;
    
    if (!item)
    {
        _collectionIndex++;
        _currentCollection = _collections[_collectionIndex];
        _itemIndex = 0;
        return [self nextObject];
    }
    
    _itemIndex++;
    
    return item;
}


@end
