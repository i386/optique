//
//  OPPhotoAlbum.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoAlbum.h"

@implementation OPPhotoAlbum

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

@end
