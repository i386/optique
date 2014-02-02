//
//  OPDarkroomEditManager.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPDarkroomEditManager.h"

@interface OPDarkroomEditManager ()

@property (weak) id<XPItem> item;
@property (strong) NSMutableArray *operations;
@property (strong) CALayer *layer;

@end

@implementation OPDarkroomEditManager

-(id)initWithItem:(id<XPItem>)item previewLayer:(CALayer*)layer
{
    self = [super init];
    if (self)
    {
        _item = item;
        _operations = [NSMutableArray array];
        _layer = layer;
    }
    return self;
}

-(void)addOperation:(id<OPDarkroomEditOperation>)operation
{
    [_operations addObject:operation];
    [operation performPreviewOperation:_layer];
    
    [operation performWithItem:_item];
}

@end
