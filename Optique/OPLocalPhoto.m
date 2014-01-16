//
//  OPLocalPhoto.m
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "OPLocalPhoto.h"
#import "NSURL+EqualToURL.h"
#import "NSURL+URLWithoutQuery.h"

@implementation OPLocalPhoto

-(id)initWithTitle:(NSString *)title path:(NSURL *)path album:(id<XPPhotoCollection>)collection type:(XPPhotoType)type
{
    self = [super init];
    if (self)
    {
        _title = title;
        _path = path;
        _collection = collection;
        _type = type;
    }
    return self;
}

-(void)scaleImageToFitSize:(NSSize)size withCompletionBlock:(XPImageCompletionBlock)completionBlock
{
    NSImage *image;
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)_path, NULL);
    if (imageSource != nil)
    {
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        if (imageProperties != nil)
        {
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
            
            CFRelease(imageProperties);
        }
        else
        {
            NSLog(@"Could not get image properties for '%@'", _path);
        }
        
        CFRelease(imageSource);
    }
    else
    {
        NSLog(@"Could not create image src for '%@'", _path);
    }
    
    completionBlock(image);
}

-(NSDate *)created
{
    if (__created == nil)
    {
        NSDictionary* attributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[_path path] error: NULL];
        __created = attributesDictionary[NSFileCreationDate];
    }
    return __created;
}

-(NSURL *)url
{
    return _path;
}

-(BOOL)hasLocalCopy
{
    return YES;
}

-(NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[XPPhotoPboardType, (NSString *)kUTTypeURL];
}

-(id)pasteboardPropertyListForType:(NSString *)type
{
    if ([type isEqualToString:XPPhotoPboardType])
    {
        return [NSKeyedArchiver archivedDataWithRootObject:@{@"photo-title": self.title, @"collection-title": [self.collection title]}];
    }
    else if ([type isEqualToString:(NSString *)kUTTypeURL])
    {
        return [self.url pasteboardPropertyListForType:(NSString *)kUTTypeURL];
    }
    return nil;
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPLocalPhoto *photo = object;
    return [self.path.path isEqualToString:photo.path.path];
}

-(NSUInteger)hash
{
    return self.path.path.hash;
}

@end
