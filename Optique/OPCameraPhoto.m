//
//  OPCameraFile.m
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraPhoto.h"

@interface OPCameraPhoto() {
    ICCameraFile *_cameraFile;
    id<OPPhotoCollection> _collection;
}
@end

@implementation OPCameraPhoto

-(id)initWithCameraFile:(ICCameraFile *)cameraFile collection:(id<OPPhotoCollection>)collection
{
    self = [super init];
    if (self)
    {
        _cameraFile = cameraFile;
        _collection = collection;
    }
    return self;
}

-(NSString *)title
{
    return _cameraFile.name;
}

-(id<OPPhotoCollection>)collection
{
    return _collection;
}

-(NSImage *)thumbnail
{
    ICCameraDevice *device = _cameraFile.device;
    if (!device.hasOpenSession)
    {
        [device requestOpenSession];
    }
    
    if (_cameraFile.thumbnailIfAvailable)
    {
        return [[NSImage alloc] initWithCGImage:_cameraFile.thumbnailIfAvailable size:NSMakeSize(260, 175)];
    }
    
    return nil;
}

-(NSImage *)image
{
    return nil;
}

-(NSImage *)scaleImageToFitSize:(NSSize)size
{
    return nil;
}

@end
