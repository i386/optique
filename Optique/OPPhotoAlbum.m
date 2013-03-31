//
//  OPPhotoAlbum.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoAlbum.h"
#import "OPPhoto.h"

@implementation OPPhotoAlbum

-(id)initWithTitle:(NSString *)title path:(NSURL *)path
{
    self = [super init];
    if (self)
    {
        _title = title;
        _path = path;
    }
    return self;
}

-(NSImage *)coverImage
{
    OPPhoto *photo = [[self allPhotos] objectAtIndex:0];
    return photo.coverImage;
}

-(NSArray *)allPhotos
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:_path includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
                                             NSLog(@"error: %@", error.userInfo);
                                             return YES;
                                         }];
    
    for (NSURL *url in enumerator)
    {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error])
        {
            //TODO handle error
        }
        else if (![isDirectory boolValue])
        {
            NSString *filePath = [url path];
            CFStringRef fileExtension = (__bridge CFStringRef) [filePath pathExtension];
            CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
            
            if (UTTypeConformsTo(fileUTI, kUTTypeImage))
            {
                OPPhoto *photo = [[OPPhoto alloc] initWithTitle:[filePath lastPathComponent] path:url];
                [photos addObject:photo];
            }
        }
    }

    
    return photos;
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPPhotoAlbum *otherAlbum = object;
    return [self.path isEqual:otherAlbum.path];
}

@end
