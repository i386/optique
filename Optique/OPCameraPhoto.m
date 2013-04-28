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

-(NSImage *)image
{
    if (!_fileDownloaded)
    {
        if (!_cameraFile.device.hasOpenSession)
        {
            [_cameraFile.device requestOpenSession];
        }
        
        [_cameraFile.device requestReadDataFromFile:_cameraFile atOffset:0 length:_cameraFile.fileSize readDelegate:self didReadDataSelector:@selector(didReadData:fromFile:error:contextInfo:) contextInfo:NULL];
        
        return nil;
    }

    return [[NSImage alloc] initByReferencingURL:[self.camera.cacheDirectory URLByAppendingPathComponent:self.title]];;
}

- (void)didReadData:(NSData*)data fromFile:(ICCameraFile*)file error:(NSError*)error contextInfo:(void*)contextInfo
{
#if DEBUG
    NSLog(@"Downloading image '%@' from camera '%@'", file.name, file.device.name);
#endif
    
    NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    
    NSURL *fileURL = [self.camera.cacheDirectory URLByAppendingPathComponent:file.name];
    [data writeToURL:fileURL atomically:YES];
    _fileDownloaded = YES;
    
    [[self.collection photoManager] collectionUpdated:self.collection];
}

-(NSImage *)scaleImageToFitSize:(NSSize)size
{
    return self.image;
}

@end
