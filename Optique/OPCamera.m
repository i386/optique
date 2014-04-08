//
//  OPImageCaptureDevice.m
//  Optique
//
//  Created by James Dumay on 26/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCamera.h"
#import "OPCameraItem.h"
#import "OPCameraService.h"
#import "ICCameraDevice+OrderedMediaFiles.h"

#define kOPCameraIPhotoPath @"/Applications/iPhoto"

@interface OPCamera()

@property (strong) NSMutableOrderedSet *allItems;
@property (strong) NSMutableDictionary *thumbnails;
@property (weak) OPCameraService *cameraService;

@end

@implementation OPCamera

-(id)initWithDevice:(ICCameraDevice *)device collectionManager:(XPCollectionManager *)collectionManager service:(OPCameraService *)service
{
    self = [super init];
    if (self)
    {
        _allItems = [[NSMutableOrderedSet alloc] init];
        _thumbnails = [NSMutableDictionary dictionary];
        _collectionManager = collectionManager;
        _device = device;
        _device.delegate = self;
        _created = [NSDate date];
        _cameraService = service;
        _title = device.name;
    }
    return self;
}

-(NSArray *)itemsAtIndexes:(NSIndexSet *)indexSet
{
    NSMutableArray *items = [NSMutableArray array];
    
    [self.allItems enumerateObjectsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         [items addObject:obj];
     }];
    
    return items;
}

-(id<XPItem>)coverItem
{
    if (_allItems.count > 0)
    {
        return _allItems[0];
    }
    return nil;
}

-(void)requestEject
{
    [_device requestEjectOrDisconnect];
}

-(BOOL)isLocked
{
    return [_device isAccessRestrictedAppleDevice];
}

-(void)reload
{
    NSMutableOrderedSet *newItems = [NSMutableOrderedSet orderedSet];
    for (ICCameraFile *cameraFile in self.device.orderedMediaFiles)
    {
        XPItemType type = XPItemTypeFromUTINSString(cameraFile.UTI);
        if (type != XPItemTypeUnknown)
        {
            OPCameraItem *item = [[OPCameraItem alloc] initWithCameraFile:cameraFile collection:self type:type];
            if ([cameraFile thumbnailIfAvailable] || [cameraFile largeThumbnailIfAvailable])
            {
                [newItems addObject:item];
            }
        }
    }
    _allItems = newItems;
}

-(XPItemCollectionType)collectionType
{
    return XPItemCollectionCamera;
}

-(BOOL)hasLocalCopy
{
    return NO;
}

-(BOOL)isDefaultApp
{
    return [[[NSBundle mainBundle] bundlePath] isEqualToString:_device.autolaunchApplicationPath];
}

-(void)setDefaultApp:(BOOL)defaultApp
{
    if (defaultApp)
    {
        _device.autolaunchApplicationPath = [NSBundle mainBundle].bundlePath;
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:kOPCameraIPhotoPath])
    {
        _device.autolaunchApplicationPath = kOPCameraIPhotoPath;
    }
    else
    {
        _device.autolaunchApplicationPath = nil;
    }
}

-(void)deleteItem:(id<XPItem>)item withCompletion:(XPCompletionBlock)completionBlock
{
    OPCameraItem *cameraItem = (OPCameraItem*)item;
    [cameraItem.cameraFile.device requestDeleteFiles:@[cameraItem.cameraFile]];
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
        [_allItems removeObject:cameraFile];
        [_thumbnails removeObjectForKey:cameraFile.name];
    }
    
    [self.collectionManager collectionUpdated:self reload:NO];
}

- (void)deviceDidBecomeReadyWithCompleteContentCatalog:(ICDevice*)device
{
#if DEBUG
    NSLog(@"Camera '%@' is now ready to accept commands", device.name);
#endif
    
    for (ICCameraFile *file in self.device.orderedMediaFiles)
    {
        [file thumbnailIfAvailable];
        [file largeThumbnailIfAvailable];
        
        XPItemType type = XPItemTypeFromUTINSString(file.UTI);
        if (type != XPItemTypeUnknown)
        {
            OPCameraItem *cameraItem = [[OPCameraItem alloc] initWithCameraFile:file collection:self type:type];
            [_allItems addObject:cameraItem];
        }
    }
    
    [_cameraService didAddCamera:self];
    [_collectionManager collectionUpdated:self reload:NO];
}

-(void)device:(ICDevice *)device didEncounterError:(NSError *)error
{
    NSLog(@"Error encountered while comminicating with camera '%@' Error: '%@'", device.name, error);
}

-(void)device:(ICDevice *)device didOpenSessionWithError:(NSError *)error
{
    if (!error)
    {
#if DEBUG
        NSLog(@"Session opened for camera '%@'", device.name);
#endif
    }
}

- (void)collectionUpdated:(NSDictionary*)userInfo
{
    [_collectionManager collectionUpdated:self reload:YES];
}

- (void)cameraDevice:(ICCameraDevice*)device didReceiveThumbnailForItem:(ICCameraItem*)item
{
    XPItemType type = XPItemTypeFromUTINSString(item.UTI);
    if (type != XPItemTypeUnknown)
    {
        OPCameraItem *cameraItem = [[OPCameraItem alloc] initWithCameraFile:(ICCameraFile*)item collection:self type:type];
        [_allItems addObject:cameraItem];
        
        CGImageRef thumbnail = item.largeThumbnailIfAvailable;
        if (!thumbnail)
        {
            thumbnail = item.thumbnailIfAvailable;
        }
        
        NSSize size = NSMakeSize(CGImageGetWidth(thumbnail), CGImageGetHeight(thumbnail));
        NSImage *image = [[NSImage alloc] initWithCGImage:thumbnail size:size];
        
        [_thumbnails setObject:image forKey:item.name];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:XPItemWillReload object:nil userInfo:@{@"item": cameraItem}];
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

-(BOOL)isEqualTo:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPCamera *otherDevice = object;
    return [self.device isEqualTo:otherDevice.device];
}

-(NSUInteger)hash
{
    return _device.hash;
}

@end
