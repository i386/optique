//
//  OPCameraFile.m
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraPhoto.h"
#import "OPCamera.h"

@interface OPCameraPhotoCondition : NSConditionLock

@property (readonly, strong) XPURLSupplier supplier;

@end

@implementation OPCameraPhotoCondition

-initWithURLSupplier:(XPURLSupplier)supplier
{
    self = [super initWithCondition:0];
    if (self)
    {
        _supplier = supplier;
    }
    return self;
}

@end

@interface OPCameraPhoto() {
    volatile BOOL _fileDownloaded;
}
@property (readonly, strong) NSURL *localURL;
@end

@implementation OPCameraPhoto

-(id)initWithCameraFile:(ICCameraFile *)cameraFile collection:(id<XPPhotoCollection>)collection
{
    self = [super init];
    if (self)
    {
        _cameraFile = cameraFile;
        _collection = collection;
        _fileDownloaded = NO;
    }
    return self;
}

-(NSString *)title
{
    return _cameraFile.name;
}

-(OPCamera*)camera
{
    return (OPCamera*)_collection;
}

-(NSDate *)created
{
    return _cameraFile.creationDate;
}

-(NSImage *)thumbnail
{
    NSImage *thumbnail = [((OPCamera*)_collection) thumbnailForName:self.title];
    return thumbnail;
}

-(void)imageWithCompletionBlock:(XPImageCompletionBlock)completionBlock
{
    if (!_fileDownloaded)
    {
        [_cameraFile.device requestReadDataFromFile:_cameraFile atOffset:0 length:_cameraFile.fileSize readDelegate:self didReadDataSelector:@selector(didReadData:fromFile:error:contextInfo:) contextInfo:(void*)CFBridgingRetain(completionBlock)];
    }
    else
    {
        NSImage  *image = [[NSImage alloc] initByReferencingURL:[self.camera.cacheDirectory URLByAppendingPathComponent:self.title]];
        completionBlock(image);
    }
}


-(void)scaleImageToFitSize:(NSSize)size withCompletionBlock:(XPImageCompletionBlock)completionBlock
{
    [self imageWithCompletionBlock:completionBlock];
}

-(NSURL *)url
{
    if (!_fileDownloaded)
    {
        NSConditionLock *condition = [[NSConditionLock alloc] init];
        [condition lock];
        
        [_cameraFile.device requestReadDataFromFile:_cameraFile atOffset:0 length:_cameraFile.fileSize readDelegate:self didReadDataSelector:@selector(didLoadData:fromFile:error:contextInfo:) contextInfo:(void*)CFBridgingRetain(condition)];
        
        [condition lock];
        [condition unlockWithCondition:1];
    }
    return _localURL;
}

- (void)didLoadData:(NSData*)data fromFile:(ICCameraFile*)file error:(NSError*)error contextInfo:(void*)context
{
#if DEBUG
    NSLog(@"Downloading image '%@' from camera '%@'", file.name, file.device.name);
#endif
    
    NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    
    NSURL *fileURL = [self.camera.cacheDirectory URLByAppendingPathComponent:file.name];
    [data writeToURL:fileURL atomically:YES];
    _fileDownloaded = YES;
    
    OPCameraPhotoCondition *condition = CFBridgingRelease(context);
    _localURL = fileURL;
    [condition unlockWithCondition:1];
}

- (void)didReadData:(NSData*)data fromFile:(ICCameraFile*)file error:(NSError*)error contextInfo:(void*)context
{
#if DEBUG
    NSLog(@"Downloading image '%@' from camera '%@'", file.name, file.device.name);
#endif
    
    NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    
    NSURL *fileURL = [self.camera.cacheDirectory URLByAppendingPathComponent:file.name];
    [data writeToURL:fileURL atomically:YES];
    _fileDownloaded = YES;
    
    [[self.collection photoManager] collectionUpdated:self.collection];
    
    NSImage *image = [[NSImage alloc] initByReferencingURL:fileURL];
    
    XPImageCompletionBlock completionBlock = CFBridgingRelease(context);
    completionBlock(image);
}

@end
