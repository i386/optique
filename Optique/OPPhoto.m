//
//  OPPhoto.m
//  Optique
//
//  Created by James Dumay on 21/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhoto.h"
#import "NSImage+MGCropExtensions.h"
#import "OPImageCache.h"

@implementation OPPhoto

-(id)initWithTitle:(NSString *)title path:(NSURL *)path
{
    self = [super init];
    if (self)
    {
        _title = title;
        _path = path;
    }
    return self;
}

-(NSImage*)image
{
    return [[NSImage alloc] initWithContentsOfURL:_path];
}

-(NSImage*)scaleImageToFitSize:(NSSize)size
{
    NSImage *image;
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)_path, NULL);
    
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    CFNumberRef pixelWidthRef  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
    CFNumberRef pixelHeightRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
    CGFloat pixelWidth = [(__bridge NSNumber *)pixelWidthRef floatValue];
    CGFloat pixelHeight = [(__bridge NSNumber *)pixelHeightRef floatValue];
    CGFloat maxEdge = MAX(pixelWidth, pixelHeight);
    
    float maxEdgeSize = MAX(size.width, size.height);
    
    if (maxEdge > maxEdgeSize)
    {
        NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue,
                                          kCGImageSourceCreateThumbnailWithTransform, kCFBooleanTrue,
                                          kCGImageSourceCreateThumbnailFromImageAlways, [NSNumber numberWithFloat:maxEdgeSize],
                                          kCGImageSourceThumbnailMaxPixelSize, nil];
        CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)thumbnailOptions);
        
        image = [[NSImage alloc] initWithCGImage:thumbnail size:NSMakeSize(CGImageGetWidth(thumbnail), CGImageGetHeight(thumbnail))];
    }
    else
    {
        image = [[NSImage alloc] initWithContentsOfURL:_path];
    }
    
    CFRelease(imageProperties);
    
    return image;
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPPhoto *photo = object;
    return [self.path isEqual:photo.path];
}

-(NSUInteger)hash
{
    return self.path.hash;
}

@end
