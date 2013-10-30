//
//  OPGridView.m
//  Optique
//
//  Created by James Dumay on 14/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPGridView.h"
#import "NSPasteboard+XPPhoto.h"
#import "OPCollectionViewController.h"

#define kGridViewRowSpacing 40.f
#define kGridViewColumnSpacing 20.f

@implementation OPGridView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.minimumColumnSpacing = kGridViewColumnSpacing;
        self.rowSpacing = kGridViewRowSpacing;
        self.itemSize = CGSizeMake(280.0, 175.0);
        
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }
    return self;
}

-(void)copy:(id)sender
{
    NSArray *filteredCollections = [_controller.photoManager.allCollections filteredArrayUsingPredicate:_controller.predicate];
    NSArray *selectedItems = [filteredCollections objectsAtIndexes:_controller.selectedItems];
    
    if (selectedItems.count > 0)
    {
        NSMutableArray *urls = [NSMutableArray array];
        
        for (id<XPPhotoCollection> collection in selectedItems)
        {
            [urls addObject:collection.path];
        }
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [pasteboard writeObjects:urls];
    }
}

@end
