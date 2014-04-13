//
//  OPImage.m
//  Optique
//
//  Created by James Dumay on 13/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPImage.h"

@implementation OPImage

-(id)initWithCGImageRef:(CGImageRef)imageRef properties:(NSDictionary *)properties
{
    self = [super init];
    if (self)
    {
        _imageRef = imageRef;
        _properties = [NSMutableDictionary dictionaryWithDictionary:properties];
    }
    return self;
}

@end
