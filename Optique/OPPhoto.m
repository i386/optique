//
//  OPPhoto.m
//  Optique
//
//  Created by James Dumay on 21/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhoto.h"

@implementation OPPhoto

-(id)initWithName:(NSString *)name path:(NSURL *)path
{
    self = [super init];
    if (self)
    {
        _name = name;
        _path = path;
    }
    return self;
}

-(NSImage *)image
{
    return [[NSImage alloc] initWithContentsOfURL:_path];
}

@end
