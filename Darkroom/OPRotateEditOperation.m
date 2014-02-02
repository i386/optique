//
//  OPRotateEditOperation.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPRotateEditOperation.h"
#import "CALayer+Rotate.h"

@implementation OPRotateEditOperation

-(void)performPreviewOperation:(CALayer *)layer
{
    [layer rotateByDegrees:90];
    [layer setBounds:layer.superlayer.bounds];
    [layer setFrame:layer.superlayer.frame];
}

-(void)performWithItem:(id<XPItem>)item
{
    CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)(item.url), nil);
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, nil);
    NSLog(@"Image properties %@", (__bridge NSDictionary*)properties);
    CFNumberRef orientation = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
    
    NSInteger value;
    CFNumberGetValue(orientation, kCFNumberNSIntegerType, &value);
    value++;
    
    CFMutableDictionaryRef newImageProperties = CFDictionaryCreateMutableCopy(nil, 0, properties);
    
    orientation = CFNumberCreate(NULL, kCFNumberNSIntegerType, &value);
    
    CFDictionaryAddValue(newImageProperties, kCGImagePropertyOrientation, (void *)(orientation));
    
    CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)(item.url), CGImageSourceGetType(sourceRef), 0, nil);
    CGImageDestinationAddImageFromSource(destinationRef, sourceRef, 0, nil);
    CGImageDestinationSetProperties(destinationRef, newImageProperties);
    CGImageDestinationFinalize(destinationRef);
}

@end
