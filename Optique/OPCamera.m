//
//  OPImageCaptureDevice.m
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCamera.h"
#import "OPCameraPhoto.h"

@interface OPCamera() {
    NSMutableArray *_allPhotos;
    NSMutableDictionary *_thumbnails;
    NSTimer *_batchTimer;
    NSUInteger _thumbnailsRecieved;
}
@end

@implementation OPCamera

-(id)initWithDevice:(ICCameraDevice *)device photoManager:(XPPhotoManager *)photoManager
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
        _created = [NSDate date];
    }
    return self;
}

-(NSString *)title
{
    return _device.name;
}

-(NSArray *)allPhotos
{
    return [_allPhotos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]]];
}

-(NSArray *)photosForIndexSet:(NSIndexSet *)indexSet
{
    NSMutableArray *photos = [NSMutableArray array];
    
    [self.allPhotos enumerateObjectsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         [photos addObject:obj];
     }];
    
    return photos;
}

-(id<XPPhoto>)coverPhoto
{
    if (_allPhotos.count > 0)
    {
        return _allPhotos[0];
    }
    return nil;
}

-(void)requestEject
{
    [_device requestEjectOrDisconnect];
}

-(void)reload
{
    NSMutableArray *newPhotos = [NSMutableArray array];
    for (ICCameraFile *cameraFile in self.device.mediaFiles)
    {
        OPCameraPhoto *photo = [[OPCameraPhoto alloc] initWithCameraFile:cameraFile collection:self];
        [newPhotos addObject:photo];
    }
    _allPhotos = newPhotos;
}

-(XPPhotoCollectionType)collectionType
{
    return kPhotoCollectionCamera;
}

-(void)deletePhoto:(id<XPPhoto>)photo withCompletion:(XPCompletionBlock)completionBlock
{
    OPCameraPhoto *cameraPhoto = (OPCameraPhoto*)photo;
    [cameraPhoto.cameraFile.device requestDeleteFiles:@[cameraPhoto.cameraFile]];
    if (completionBlock)
    {
        completionBlock(nil);
    }
}

-(NSImage *)thumbnailForName:(NSString *)name
{
    return [_thumbnails objectForKey:name];
}

-(void)cameraDevice:(ICCameraDevice *)camera didRemoveItems:(NSArray *)items
{
#if DEBUG
    NSLog(@"%lu items were removed from camera '%@'", items.count, camera.name);
#endif
    
    //Remove the thumbnails from memory
    for (ICCameraFile *cameraFile in items)
    {
        [_thumbnails removeObjectForKey:cameraFile.name];
    }
    
    [self.photoManager collectionUpdated:self];
}

- (void)deviceDidBecomeReadyWithCompleteContentCatalog:(ICDevice*)device
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

- (void)collectionUpdated:(NSDictionary*)userInfo
{
    [_photoManager collectionUpdated:self];
}

- (void)cameraDevice:(ICCameraDevice*)device didReceiveThumbnailForItem:(ICCameraItem*)item
{
#if DEBUG
    NSLog(@"Thumbnail received from camera '%@' for item '%@'", device.name, item.name);
#endif
    
    _thumbnailsRecieved++;
    
    if (!_batchTimer)
    {   
        _batchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(collectionUpdated:) userInfo:nil repeats:YES];
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
