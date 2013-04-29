//
//  OPCameraFile.m
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraPhoto.h"
#import "OPCamera.h"

@interface OPCameraPhoto() {
    id<OPPhotoCollection> _collection;
    volatile BOOL _fileDownloaded;
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
        _fileDownloaded = NO;
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

-(OPCamera*)camera
{
    return (OPCamera*)_collection;
}

-(NSImage *)thumbnail
{
    NSImage *thumbnail = [((OPCamera*)_collection) thumbnailForName:self.title];
    return thumbnail;
}

-(void)ImageWithCompletionBlock:(void (^)(NSImage *))completionBlock
{
    if (!_fileDownloaded)
    {
        if (!_cameraFile.device.hasOpenSession)
        {
            [_cameraFile.device requestOpenSession];
        }
        
        [_cameraFile.device requestReadDataFromFile:_cameraFile atOffset:0 length:_cameraFile.fileSize readDelegate:self didReadDataSelector:@selector(didReadData:fromFile:error:contextInfo:) contextInfo:(void*)CFBridgingRetain(completionBlock)];
    }
    else
    {
        NSImage  *image = [[NSImage alloc] initByReferencingURL:[self.camera.cacheDirectory URLByAppendingPathComponent:self.title]];
        completionBlock(image);
    }
}

- (void)didReadData:(NSData*)data fromFile:(ICCameraFile*)file error:(NSError*)error contextInfo:(void (^)(NSImage*))loadBlock
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
    loadBlock(image);
}

-(void)scaleImageToFitSize:(NSSize)size withCompletionBlock:(void (^)(NSImage *))completionBlock
{
    [self ImageWithCompletionBlock:completionBlock];
}

@end
