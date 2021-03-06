/*
 * Copyright (C) 2004, 2005, 2006, 2008 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * Derivitatve of ImageSourceCG.cpp (WebCore)
 */

#import "OPImageOrientation.h"

OPImageOrientation OPImageOrientationGet(CGImageSourceRef srcImageRef)
{
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(srcImageRef, 0, NULL);
    int orientation = OPImageOrientationGetFromProperties(properties);
    CFRelease(properties);
    return orientation;
}

OPImageOrientation OPImageOrientationGetFromProperties(CFDictionaryRef properties)
{
    int orientation = OPImageOrientationUp;
    CFNumberRef orientationValue = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
    if (orientationValue != NULL)
    {
        CFNumberGetValue(orientationValue, kCFNumberIntType, &orientation);
    }
    return orientation;
}

void OPImageOrientationSet(CFMutableDictionaryRef properties, OPImageOrientation orientation)
{
    CFNumberRef orientationValue = CFNumberCreate(kCFAllocatorDefault, kCFNumberShortType, &orientation);
    CFDictionarySetValue(properties, kCGImagePropertyOrientation, orientationValue);
}