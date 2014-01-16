
#include "XPPhoto.h"

XPPhotoType XPPhotoTypeFromUTICFString(CFStringRef fileUTI)
{
    XPPhotoType type = XPPhotoTypeUnknown;
    if (UTTypeConformsTo(fileUTI, kUTTypeImage))
    {
        type = XPPhotoTypePhoto;
    }
    
//    if (UTTypeConformsTo(fileUTI, kUTTypeMovie) ||
//        UTTypeConformsTo(fileUTI, kUTTypeVideo))
//    {
//        type = XPPhotoTypeVideo;
//    }
    
    return type;
}

XPPhotoType XPPhotoTypeFromUTINSString(NSString *fileUTI)
{
    return XPPhotoTypeFromUTICFString((__bridge CFStringRef)(fileUTI));
}