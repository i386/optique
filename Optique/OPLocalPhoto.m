//
//  OPLocalPhoto.m
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPLocalPhoto.h"
#import "NSURL+EqualToURL.h"
#import "NSURL+URLWithoutQuery.h"

@implementation OPLocalPhoto

-(id)initWithTitle:(NSString *)title path:(NSURL *)path album:(id<XPPhotoCollection>)collection
{
    self = [super init];
    if (self)
    {
        _title = title;
        _path = path;
        _collection = collection;
        
        NSDictionary* attributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[_path path] error: NULL];
        _created = attributesDictionary[NSFileCreationDate];
    }
    return self;
}

-(void)scaleImageToFitSize:(NSSize)size withCompletionBlock:(XPImageCompletionBlock)completionBlock
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
                                          kCGImageSourceThumbnailMaxPixelSize, kCFBooleanFalse, kCGImageSourceShouldCache, nil];
        
        CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)thumbnailOptions);
        
        image = [[NSImage alloc] initWithCGImage:thumbnail size:NSMakeSize(CGImageGetWidth(thumbnail), CGImageGetHeight(thumbnail))];
        
        CGImageRelease(thumbnail);
    }
    else
    {
        image = [[NSImage alloc] initWithContentsOfURL:_path];
    }
    
    CFRelease(imageSource);
    CFRelease(imageProperties);
    
    completionBlock(image);
}

-(NSURL *)url
{
    return _path;
}

-(BOOL)hasLocalCopy
{
    return YES;
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPLocalPhoto *photo = object;
    return [[[self path] URLWithoutQuery] isEqualToURL:[photo.path URLWithoutQuery]];
}

-(NSUInteger)hash
{
    return self.path.URLWithoutQuery.hash;
}

@end
