//
//  OPDarkroomEditManager.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPDarkroomManager.h"
#import "NSURL+Renamer.h"
#import "NSObject+PerformBlock.h"
#import "CIImage+CGImageRef.h"

@interface OPDarkroomManager ()

@property (weak) id<XPItem> item;
@property (strong) NSMutableArray *optimizers;
@property (strong, nonatomic) NSMutableArray *operations;
@property (strong) CALayer *layer;
@property (strong) OPImage* image;

@end

@implementation OPDarkroomManager

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
        _optimizers = [NSMutableArray array];
        _layer = layer;
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCGImageSourceShouldCache, kCFBooleanFalse, nil];
        CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)(_item.url), (__bridge CFDictionaryRef)(options));
        if (sourceRef)
        {
            CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, nil);
            CFMutableDictionaryRef newImageProperties = CFDictionaryCreateMutableCopy(nil, 0, properties);
            
            CGImageRef theImage = CGImageSourceCreateImageAtIndex(sourceRef, 0, nil);
            if (theImage)
            {
                _image = [[OPImage alloc] initWithCGImageRef:theImage properties:(__bridge NSDictionary *)(newImageProperties)];
            }
            CFRelease(sourceRef);
        }
    }
    return self;
}

-(NSUInteger)count
{
    return _operations.count;
}

-(NSArray *)operations
{
    __block NSArray *ops = _operations;
    [_optimizers bk_each:^(id<OPDarkroomOperationOptimizer> obj) {
        ops = [obj optimize:ops];
    }];
    return ops;
}

-(void)addOptimizer:(id<OPDarkroomOperationOptimizer>)optimizer
{
    [_optimizers addObject:optimizer];
}

-(void)addOperation:(id<OPDarkroomOperation>)operation
{
    [_operations addObject:operation];
    _image = [operation perform:_image layer:_layer];
}

-(void)commit
{
    //Load original with metadata
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCGImageSourceShouldCache, kCFBooleanFalse, nil];
    CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)(_item.url), (__bridge CFDictionaryRef)(options));
    if (sourceRef)
    {
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, nil);
        CFMutableDictionaryRef newImageProperties = CFDictionaryCreateMutableCopy(nil, 0, properties);
        
        CGImageRef theImage = CGImageSourceCreateImageAtIndex(sourceRef, 0, nil);
        if (theImage)
        {
            __block OPImage *image = [[OPImage alloc] initWithCGImageRef:theImage properties:(__bridge NSDictionary *)(properties)];
            [self.operations bk_each:^(id<OPDarkroomOperation> operation) {
                image = [operation perform:image layer:nil];
            }];
            
            NSURL *url = _item.url;
            CFStringRef sourceImageType = CGImageSourceGetType(sourceRef);
            CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)(url), sourceImageType, 0, nil);
            if (!destinationRef)
            {
                url = [[[_item.url URLByDeletingPathExtension] URLByAppendingPathExtension:@"tiff"] URLWithUniqueNameIfExistsAtParent];
                destinationRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)(url), kUTTypeTIFF, 0, nil);
            }
            
            if (destinationRef)
            {
                CGImageDestinationAddImage(destinationRef, image.image.imageRef, newImageProperties);
                CGImageDestinationFinalize(destinationRef);
                CFRelease(destinationRef);
            }
            else
            {
                NSLog(@"OPDarkroomManager: Could not create image destination for rotated image %@", _item.url);
            }
            CGImageRelease(theImage);
        }
        else
        {
            NSLog(@"OPDarkroomManager: Could not create image %@", _item.url);
        }
        
        CFRelease(sourceRef);
    }
    else
    {
        NSLog(@"OPDarkroomManager: Could not create image source %@", _item.url);
    }
}

@end
