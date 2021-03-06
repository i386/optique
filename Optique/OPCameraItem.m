//
//  OPCameraFile.m
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraItem.h"
#import "OPCamera.h"
#import "NSObject+PerformBlock.h"
#import "NSURL+Renamer.h"


@interface OPCameraItem() {
    volatile BOOL _fileDownloadRequested;
}
@end

@implementation OPCameraItem

-(id)initWithCameraFile:(ICCameraFile *)cameraFile collection:(id<XPItemCollection>)collection type:(XPItemType)type
{
    self = [super init];
    if (self)
    {
        _cameraFile = cameraFile;
        _collection = collection;
        _fileDownloadRequested = NO;
        _type = type;
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

-(NSURL *)url
{
    return _path;
}

- (void)didDownloadFile:(ICCameraFile*)file error:(NSError*)error options:(NSDictionary*)options contextInfo:(void*)contextInfo
{
    //Do not set the path if its the cached version
    OPCamera *camera = (OPCamera*)_collection;
    if ([options[ICDownloadsDirectoryURL] isEqual:[camera cacheDirectory]])
    {
        _path = [camera.cacheDirectory URLByAppendingPathComponent:file.name];
    }
    
    XPCompletionBlock callback = CFBridgingRelease(contextInfo);
    callback(nil);
}

-(void)requestLocalCopyInCacheWhenDone:(XPCompletionBlock)callback
{
    OPCamera *camera = (OPCamera*)_collection;
    [self requestLocalCopy:[camera cacheDirectory] whenDone:callback];
}

-(void)requestLocalCopy:(NSURL *)directory whenDone:(XPCompletionBlock)callback
{
    if (_path == nil && !_fileDownloadRequested)
    {
        _fileDownloadRequested = YES;
        
        NSURL *renamedUrl = [[directory URLByAppendingPathComponent:_cameraFile.name] URLWithUniqueNameIfExistsAtParent];
        NSString *filename = [renamedUrl lastPathComponent];
        
        NSDictionary* options = @{ICDownloadsDirectoryURL: directory, ICSaveAsFilename: filename};
        
        [_cameraFile.device requestDownloadFile:_cameraFile options:options downloadDelegate:self didDownloadSelector:@selector(didDownloadFile:error:options:contextInfo:) contextInfo:(void*)CFBridgingRetain(callback)];
    }
}

-(BOOL)hasLocalCopy
{
    return _path != nil;
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPCameraItem *item = object;
    return [self.cameraFile isEqual:item.cameraFile];
}

-(NSUInteger)hash
{
    return self.cameraFile.hash;
}

@end
