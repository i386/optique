//
//  OPGridView.m
//  Optique
//
//  Created by James Dumay on 27/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPGridView.h"

#define DefaultItemSize CGSizeMake(280.0, 175.0);

@implementation OPGridView

-(id)init
{
    self = [super init];
    if (self)
    {
        _ignoreSizePreference = NO;
    }
    return self;
}

-(void)selectAll:(id)sender
{
    [super selectAll:sender];
}

-(void)deselectAll:(id)sender
{
    [super deselectAll:sender];
}

-(void)selectCellAtIndex:(NSUInteger)idx
{
    [super selectCellAtIndex:idx];
}

-(void)deselectCellAtIndex:(NSUInteger)idx
{
    [super deselectCellAtIndex:idx];
}

-(void)setIgnoreSizePreference:(BOOL)ignoreSizePreference
{
    _ignoreSizePreference = ignoreSizePreference;
    if (_ignoreSizePreference)
    {
        self.itemSize = DefaultItemSize;
    }
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"ItemSize"
                                               options:NSKeyValueObservingOptionNew
                                               context:NULL];
    
    NSUInteger size = [[NSUserDefaults standardUserDefaults] integerForKey:@"ItemSize"];
    [self resizeItem:size];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (_ignoreSizePreference)
    {
        self.itemSize = DefaultItemSize;
    }
    else
    {
        NSNumber *factor = (NSNumber*)change[@"new"];
        [self resizeItem:[factor unsignedIntegerValue]];
    }
}

-(void)resizeItem:(NSUInteger)factor
{
    CGSize size = DefaultItemSize;
    
    switch (factor) {
        case 0:
            size = NSMakeSize(size.width / 2, size.height / 2);
            break;
            
        case 25:
            size = NSMakeSize(size.width / 1.5, size.height / 1.5);
            break;
            
        case 75:
            size = NSMakeSize(size.width * 1.5, size.height * 1.5);
            break;
            
        case 100:
            size = NSMakeSize(size.width * 2, size.height * 2);
            break;
            
        default:
            size = DefaultItemSize;
            break;
    }
    
    self.itemSize = size;
}

@end
