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
    OPPhotoManager *_photoManager;
    CHReadWriteLock *_arrayLock;
    NSMutableArray *_allPhotos;
    NSMutableDictionary *_thumbnails;
    NSTimer *_batchTimer;
    NSUInteger _thumbnailsRecieved;
}
@end

@implementation OPCamera

-(id)initWithDevice:(ICCameraDevice *)device photoManager:(OPPhotoManager *)photoManager
{
    self = [super init];
    if (self)
    {
        _allPhotos = [[NSMutableArray alloc] init];
        _thumbnails = [NSMutableDictionary dictionary];
        _photoManager = photoManager;
        _device = device;
        _device.delegate = self;
        _thumbnailsRecieved = 0;
    }
    return self;
}

-(OPPhotoManager *)photoManager
{
    return _photoManager;
}

-(NSString *)title
{
    return _device.name;
}

-(NSArray *)allPhotos
{
    return _allPhotos;
}

-(NSArray *)photosForIndexSet:(NSIndexSet *)indexSet
{
    NSMutableArray *photos = [NSMutableArray array];
    
    [_allPhotos enumerateObjectsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         [photos addObject:obj];
     }];
    
    return _allPhotos;
}

-(void)reloadPhotos
{
    //TODO: implement reloading for changes on camera. Unlikely we will need this yet...
}

-(NSImage *)thumbnailForName:(NSString *)name
{
    return [_thumbnails objectForKey:name];
}

-(void)deviceDidBecomeReady:(ICDevice *)device
{
#if DEBUG
    NSLog(@"Camera '%@' is now ready to accept commands", device.name);
#endif
    
    for (ICCameraFile *file in _device.mediaFiles)
    {
#if DEBUG
        NSLog(@"Found image '%@' on camera '%@'. Requesting thumbnail...", file.name, device.name);
#endif
        [file thumbnailIfAvailable];
        [file largeThumbnailIfAvailable];
    }
}

-(void)device:(ICDevice *)device didEncounterError:(NSError *)error
{
    NSLog(@"Error encountered while comminicating with camera '%@' Error: '%@'", device.name, error);
}

-(void)device:(ICDevice *)device didOpenSessionWithError:(NSError *)error
{
    if (error)
    {
        NSLog(@"Session could not start for camera '%@'. Reason: %@", device.name, error);
    }
    else
    {
#if DEBUG
        NSLog(@"Session opened for camera '%@'", device.name);
#endif
    }
}

- (void)cameraDevice:(ICCameraDevice*)device didReceiveThumbnailForItem:(ICCameraItem*)item
{
#if DEBUG
    NSLog(@"Thumbnail received from camera '%@' for item '%@'", device.name, item.name);
#endif
    
    _thumbnailsRecieved++;
    
    if (!_batchTimer)
    {
        OPPhotoManager __weak *photoManager = _photoManager;
        id<OPPhotoCollection> __weak weakCollection = self;
        
        _batchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 block:^(NSTimeInterval time) {
            [photoManager collectionUpdated:weakCollection];
        } repeats:YES];
    }
    
    OPCameraPhoto *photo = [[OPCameraPhoto alloc] initWithCameraFile:(ICCameraFile*)item collection:self];
    [_allPhotos addObject:photo];
    
    CGImageRef thumbnail = item.largeThumbnailIfAvailable;
    if (!thumbnail)
    {
        thumbnail = item.thumbnailIfAvailable;
    }
    
    NSSize size = NSMakeSize(CGImageGetWidth(thumbnail), CGImageGetHeight(thumbnail));
    NSImage *image = [[NSImage alloc] initWithCGImage:thumbnail size:size];
    
    [_thumbnails setObject:image forKey:item.name];
    
    //If all the thumbnails have been recieved, stop the timer.
    if (_thumbnailsRecieved == _device.mediaFiles.count)
    {
        //Fire one more time
        [_batchTimer fire];
        
        //Stop the timer and release it
        [_batchTimer invalidate];
        _batchTimer = nil;
        _thumbnailsRecieved = 0;
    }
}

-(void)didRemoveDevice:(ICDevice *)device
{
    //no op
}

-(NSURL *)cacheDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    NSURL *cacheDirectory = [[[[[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"com.whimsy.optique" isDirectory:YES] URLByAppendingPathComponent:@"cameras" isDirectory:YES] URLByAppendingPathComponent:self.title isDirectory:YES];
    
    if (![fileManager fileExistsAtPath:[cacheDirectory path]])
    {
        [fileManager createDirectoryAtURL:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return cacheDirectory;
}

-(void)removeCacheDirectory
{
    //Delete the cameras cache on the way out
    [[NSFileManager defaultManager] removeItemAtURL:self.cacheDirectory error:nil];
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
