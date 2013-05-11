//
//  OPFacebookAlbum.m
//  Optique
//
//  Created by James Dumay on 11/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFacebookAlbum.h"

@implementation OPFacebookAlbum

-(id)initWithName:(NSString *)name albumId:(NSUInteger)albumId
{
    self = [super init];
    if (self)
    {
        _albumId = albumId;
        _name = name;
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _albumId = [[dictionary objectForKey:@"id"] unsignedIntValue];
        _name = [dictionary objectForKey:@"name"];
        _description = [dictionary objectForKey:@"description"];
        _link = [NSURL URLWithString:[dictionary objectForKey:@"link"]];
        _privacy = [dictionary objectForKey:@"privacy"];
        _canUpload = [[dictionary objectForKey:@"id"] boolValue];
    }
    return self;
}

@end
