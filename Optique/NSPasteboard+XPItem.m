//
//  NSPasteboard+XPPhoto.m
//  Optique
//
//  Created by James Dumay on 30/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSPasteboard+XPItem.h"

@implementation NSPasteboard (XPItem)

-(void)writeItem:(id<XPItem>)item
{
    NSURL *url = item.url;
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:@[url, image]];
}

-(void)writeItems:(NSArray *)items
{
    NSMutableArray *urls = [NSMutableArray array];
    for (id<XPItem> item in items)
    {
        [urls addObject:item.url];
    }
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:urls];
}

@end
