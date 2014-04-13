
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, OPImageOrientation) {
    OPImageOrientationUp            = 1, // default orientation
    OPImageOrientationDown          = 2, // 180 deg rotation
    OPImageOrientationLeft          = 3, // 90 deg CCW
    OPImageOrientationRight         = 4, // 90 deg CW
    OPImageOrientationUpMirrored    = 5, // as above but image mirrored along other axis. horizontal flip
    OPImageOrientationDownMirrored  = 6, // horizontal flip
    OPImageOrientationLeftMirrored  = 7, // vertical flip
    OPImageOrientationRightMirrored = 8, // vertical flip
};

OPImageOrientation OPImageOrientationGetFromProperties(CFDictionaryRef properties);

OPImageOrientation OPImageOrientationGet(CGImageSourceRef srcImageRef);

void OPImageOrientationSet(CFMutableDictionaryRef properties, OPImageOrientation orientation);