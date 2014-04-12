
#include "XPItem.h"

NSString *const XPItemWillReload = @"XPItemWillReload";

XPItemType XPItemTypeFromUTICFString(CFStringRef fileUTI)
{
    XPItemType type = XPItemTypeUnknown;
    if (UTTypeConformsTo(fileUTI, kUTTypeImage))
    {
        type = XPItemTypePhoto;
    }
    
    if (UTTypeConformsTo(fileUTI, kUTTypeMovie) ||
        UTTypeConformsTo(fileUTI, kUTTypeVideo))
    {
        type = XPItemTypeVideo;
    }
    
    return type;
}

XPItemType XPItemTypeFromUTINSString(NSString *fileUTI)
{
    return XPItemTypeFromUTICFString((__bridge CFStringRef)(fileUTI));
}

XPItemType XPItemTypeForPath(NSURL* url)
{
    NSString *filePath = [url path];
    CFStringRef fileExtension = (__bridge CFStringRef) [filePath pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    XPItemType type = XPItemTypeFromUTICFString(fileUTI);
    CFRelease(fileUTI);
    return type;
}

CGImageRef XPItemGetImageRef(id<XPItem> item, CGSize size)
{
    CGImageRef imageRef = NULL;
    
    if (!item)
    {
        NSLog(@"XPItemGetImageRef: Item %@ was nil", item);
        return nil;
    }
    
    if (!item.url)
    {
        NSLog(@"XPItemGetImageRef: Item url %@ was nil", item);
        return nil;
    }
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)item.url, NULL);
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
                
                imageRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)thumbnailOptions);
            }
            else
            {
                NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue,
                                                  kCGImageSourceCreateThumbnailWithTransform, kCFBooleanTrue,
                                                  kCGImageSourceCreateThumbnailFromImageAlways, kCFBooleanFalse, kCGImageSourceShouldCache, nil];
                
                imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, (__bridge CFDictionaryRef)(thumbnailOptions));
            }
            
            CFRelease(imageProperties);
        }
        else
        {
            NSLog(@"Could not get image properties for '%@'", item.url);
        }
        
        CFRelease(imageSource);
    }
    else
    {
        NSLog(@"Could not create image src for '%@'", item.url);
    }
    
    return imageRef;
}