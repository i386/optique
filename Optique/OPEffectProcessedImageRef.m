//
//  OPEffectProcessedImageRef.m
//  Optique
//
//  Created by James Dumay on 6/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPEffectProcessedImageRef.h"

@implementation OPEffectProcessedImageRef

+(id)newWithImage:(NSImage *)image effect:(NSString *)name
{
    return [[OPEffectProcessedImageRef alloc] initWithImage:image effect:name];
}

-(id)initWithImage:(NSImage *)image effect:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _image = image;
        _effect = name;
    }
    return self;
}

@end
