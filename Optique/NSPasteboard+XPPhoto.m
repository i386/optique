//
//  NSPasteboard+XPPhoto.m
//  Optique
//
//  Created by James Dumay on 30/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSPasteboard+XPPhoto.h"

@implementation NSPasteboard (XPPhoto)

-(void)writePhoto:(id<XPPhoto>)photo
{
    NSURL *url = photo.url;
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:@[url, image]];
}

-(void)writePhotos:(NSArray *)photos
{
    NSMutableArray *urls = [NSMutableArray array];
    for (id<XPPhoto> photo in photos)
    {
        [urls addObject:photo.url];
    }
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:urls];
}

@end
