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

+(BOOL)IsWritableInNativeFormat:(id<XPItem>)item
{
    BOOL writable = NO;
    
    if (!item && !item.url) return writable;
    
    static NSArray *destinationTypes;
    if (!destinationTypes)
    {
        destinationTypes = (__bridge NSArray *)(CGImageDestinationCopyTypeIdentifiers());
    }
    
    NSURL *url = item.url;
    CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)(url), nil);
    
    if (sourceRef)
    {
        CFStringRef type = CGImageSourceGetType(sourceRef);
        writable = [destinationTypes containsObject:(__bridge id)(type)];
        if (type)
        {
            CFRelease(type);
        }
    }
    else
    {
        NSLog(@"Could not check if image was writable at %@", url);
        CFRelease(sourceRef);
    }
    return writable;
}

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

-(NSUInteger)count
{
    return _operations.count;
}

-(void)addOperation:(id<OPDarkroomEditOperation>)operation
{
    [_operations addObject:operation];
    [operation performPreviewOperation:_layer];
}

-(void)commit
{
    [_operations bk_each:^(id<OPDarkroomEditOperation> operation) {
       [operation performWithItem:_item];
    }];
}

@end
