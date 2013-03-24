//
//  OPPhotoManager.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoManager.h"
#import "OPPhotoAlbum.h"

@implementation OPPhotoManager

-(id)initWithPath:(NSURL *)path
{
    self = [super init];
    if (self)
    {
        _path = path;
    }
    return self;
}

-(NSArray *)allAlbums
{
    NSMutableArray *albums = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:_path includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
                                             return YES;
                                         }];
    
    for (NSURL *url in enumerator)
    {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error])
        {
            // handle error
        }
        else if ([isDirectory boolValue])
        {
            NSString *filePath = [url path];
            CFStringRef fileExtension = (__bridge CFStringRef) [filePath pathExtension];
            CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
            
            if (!UTTypeConformsTo(fileUTI, kUTTypeDirectory))
            {
                OPPhotoAlbum *album = [[OPPhotoAlbum alloc] initWithName:[filePath lastPathComponent] path:url];
                [albums addObject:album];
            }
        }
    }
    
    return albums;
}

@end
