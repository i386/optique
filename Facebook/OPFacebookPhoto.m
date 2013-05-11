//
//  OPFacebookPhoto.m
//  Optique
//
//  Created by James Dumay on 11/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFacebookPhoto.h"

@implementation OPFacebookPhoto

-(id)initWithPhotoId:(NSUInteger)photoId name:(NSString *)photoName album:(OPFacebookAlbum *)album
{
    self = [super init];
    if (self)
    {
        _photoId = photoId;
        _name = photoName;
        _album = album;
    }
    return self;
}

@end
