//
//  OPPhoto.m
//  Optique
//
//  Created by James Dumay on 21/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhoto.h"
#import "NSImage+MGCropExtensions.h"
#import "OPImageCache.h"

@implementation OPPhoto

-(id)initWithTitle:(NSString *)title path:(NSURL *)path
{
    self = [super init];
    if (self)
    {
        _title = title;
        _path = path;
    }
    return self;
}

-(NSImage*)image
{
    return [[NSImage alloc] initWithContentsOfURL:_path];
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPPhoto *photo = object;
    return [self.path isEqual:photo.path];
}

-(NSUInteger)hash
{
    return self.path.hash;
}

@end
