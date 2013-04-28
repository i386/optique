//
//  OPImageCaptureDevice.m
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCamera.h"
#import "OPCameraPhoto.h"
#import "CHReadWriteLock.h"

@interface OPCamera() {
    CHReadWriteLock *_arrayLock;
    NSMutableArray *_allPhotos;
}
@end

@implementation OPCamera

-(id)initWithDevice:(ICCameraDevice *)device
{
    self = [super init];
    if (self)
    {
        _device = device;
        _device.delegate = self;
    }
    return self;
}

-(NSString *)title
{
    return _device.name;
}

-(NSArray *)allPhotos
{    
    [self reloadPhotos];
    
    [_arrayLock lock];
    @try
    {
        return [NSArray arrayWithArray:_allPhotos];
    }
    @finally
    {
        [_arrayLock unlock];
    }
}

-(NSArray *)photosForIndexSet:(NSIndexSet *)indexSet
{
    NSMutableArray *photos = [NSMutableArray array];
    
    [[self allPhotos] enumerateObjectsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         [photos addObject:obj];
     }];
    
    return photos;
}

-(void)reloadPhotos
{
    [_arrayLock lockForWriting];
    @try
    {
        _allPhotos = [NSMutableArray array];
        
        if (!_device.hasOpenSession)
        {
            [_device requestOpenSession];
        }
        
        [_device.mediaFiles each:^(ICCameraFile *file)
        {
            OPCameraPhoto *photo = [[OPCameraPhoto alloc] initWithCameraFile:file collection:self];
            [_allPhotos addObject:photo];
        }];
        
        [_device requestCloseSession];
    }
    @finally
    {
        [_arrayLock unlock];
    }
}

-(void)device:(ICDevice *)device didEncounterError:(NSError *)error
{
    NSLog(@"error %@", error);
}

-(void)device:(ICDevice *)device didReceiveStatusInformation:(NSDictionary *)status
{
    NSLog(@"status : %@", status);
}

-(void)device:(ICDevice *)device didOpenSessionWithError:(NSError *)error
{
    if (error)
    {
        NSLog(@"session opened with error %@", error);
    }
}

-(void)device:(ICDevice *)device didReceiveButtonPress:(NSString *)buttonType
{
    NSLog(@"recieved button press: %@", buttonType);
}

- (void)cameraDevice:(ICCameraDevice*)device didReceiveThumbnailForItem:(ICCameraItem*)item
{
    [item thumbnailIfAvailable];
    
//    NSLog( @"cameraDevice:didReceiveThumbnailForItem:\n" );
//    NSLog( @"  device: %@\n", device );
//    NSLog( @"  item:   %@\n", item );
}

//- (void)cameraDevice:(ICCameraDevice*)device didReceiveMetadataForItem:(ICCameraItem*)item
//{
//    NSLog( @"cameraDevice:didReceiveMetadataForItem:\n" );
//    NSLog( @"  device: %@\n", device );
//    NSLog( @"  item:   %@\n", item );
//}

//cameraDevice:didReceiveThumbnailForItem:

-(void)didRemoveDevice:(ICDevice *)device
{
    //no op
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPCamera *otherDevice = object;
    return [self.device isEqual:otherDevice.device];
}

-(NSUInteger)hash
{
    return _device.hash;
}

@end
