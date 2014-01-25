
#include "XPItem.h"

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