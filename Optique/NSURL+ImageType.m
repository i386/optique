//
//  NSURL+ImageType.m
//  Optique
//
//  Created by James Dumay on 3/05/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "NSURL+ImageType.h"

@implementation NSURL (ImageType)

-(CFStringRef)imageUTI
{
    //If there is no path extension, we have no idea what kind of image this is. Use PNG.
    if (!self.pathExtension) return kUTTypePNG;
    
    CFStringRef preferredIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)(self.pathExtension), kUTTypeImage);
    
    NSArray *destinationIdentifiers = (__bridge NSArray *)(CGImageDestinationCopyTypeIdentifiers());
    BOOL isWritable = preferredIdentifier ? [destinationIdentifiers containsObject:(__bridge id)(preferredIdentifier)] : NO;
    
    //If the UTI can't be determined or it wasn't writable by CG, use PNG.
    if (!preferredIdentifier || !isWritable)
    {
        return kUTTypePNG;
    }
    return preferredIdentifier;
}

@end
