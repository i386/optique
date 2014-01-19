
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