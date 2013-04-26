//
//  OPImageCaptureDevice.m
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImageCaptureDevice.h"

@implementation OPImageCaptureDevice

-(id)initWithDevice:(ICDevice *)device
{
    self = [super init];
    if (self)
    {
        _device = device;
    }
    return self;
}

-(NSArray *)allPhotos
{
    return [NSArray array];
}

-(NSArray *)photosForIndexSet:(NSIndexSet *)indexSet
{
    return [NSArray array];
}

-(void)reloadPhotos
{
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPImageCaptureDevice *otherDevice = object;
    return [self.device isEqual:otherDevice.device];
}

-(NSUInteger)hash
{
    return _device.hash;
}

@end
