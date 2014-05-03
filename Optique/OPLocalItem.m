//
//  OPLocalPhoto.m
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "OPLocalItem.h"
#import "NSURL+EqualToURL.h"
#import "NSURL+URLWithoutQuery.h"

@implementation OPLocalItem

-(id)initWithTitle:(NSString *)title path:(NSURL *)path album:(id<XPItemCollection>)collection type:(XPItemType)type
{
    self = [super init];
    if (self)
    {
        _title = title;
        _path = path;
        _collection = collection;
        _type = type;
    }
    return self;
}

-(NSDate *)created
{
    if (__created == nil)
    {
        NSDictionary* attributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[_path path] error: NULL];
        __created = attributesDictionary[NSFileCreationDate];
    }
    return __created;
}

-(NSURL *)url
{
    return _path;
}

-(BOOL)hasLocalCopy
{
    return YES;
}

-(NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[XPItemPboardType, (NSString *)kUTTypeURL, (NSString *)kUTTypeTIFF];
}

-(id)pasteboardPropertyListForType:(NSString *)type
{
    if ([type isEqualToString:XPItemPboardType])
    {
        return [NSKeyedArchiver archivedDataWithRootObject:@{@"item-title": self.title, @"collection-title": [self.collection title]}];
    }
    else if ([type isEqualToString:(NSString *)kUTTypeTIFF])
    {
        return [[[NSImage alloc] initWithContentsOfURL:self.url] pasteboardPropertyListForType:(NSString *)kUTTypeTIFF];
    }
    return nil;
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPLocalItem *item = object;
    return [self.path.path isEqualToString:item.path.path];
}

-(NSUInteger)hash
{
    return self.path.path.hash;
}

@end
