//
//  NSData+WriteImage.m
//  Optique
//
//  Created by James Dumay on 3/05/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "NSData+WriteImage.h"
#import "NSURL+Renamer.h"

@implementation NSData (WriteImage)

-(BOOL)writeImage:(NSURL *)url withUTI:(CFStringRef)uti
{
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)self, nil);
    
    if (source)
    {
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)(url), uti, 0, nil);
        
        if (destination)
        {
            CGImageDestinationAddImageFromSource(destination, source, 0, nil);
            
            if (!CGImageDestinationFinalize(destination))
            {
                NSLog(@"Couldn't write image data to %@", url);
            }
            CFRelease(source);
            return YES;
        }
        else
        {
            CFRelease(source);
        }
    }
    return NO;
}

@end
