//
//  OPFlickrPhoto.m
//  Optique
//
//  Created by James Dumay on 8/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFlickrPhoto.h"
#import "OPFlickrPhotoSet.h"

@interface OPFlickrPhoto()

@property (strong) NSNumber *flickrId;
@property (strong) NSString *title;
@property (strong) NSDate *created;
@property (strong) OPFlickrPhotoSet *photoSet;

@end

@implementation OPFlickrPhoto

-(id)initWithDictionary:(NSDictionary *)dict photoSet:(OPFlickrPhotoSet *)photoSet
{
    self = [super init];
    if (self)
    {
        _photoSet = photoSet;
        _flickrId = dict[@"id"];
        _title = dict[@"title"];
        
        NSMutableString *datetaken =  [NSMutableString stringWithString:dict[@"datetaken"]];// +0600;
        [datetaken appendString:@" +0000"];
        _created = [NSDate dateWithString:datetaken];
        
        //Try for original flickr photo
        _url = [NSURL URLWithString:dict[@"url_o"]];
        if (!_url)
        {
            _url = [photoSet.path URLByAppendingPathComponent:dict[@"filename"]];
        }
    }
    return self;
}

-(id)initWithTitle:(NSString *)title url:(NSURL *)url photoSet:(OPFlickrPhotoSet *)photoSet
{
    self = [super init];
    if (self)
    {
        _photoSet = photoSet;
        _flickrId = [NSNumber numberWithInteger:-1];
        _title = title;
        
        NSDictionary* attributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error: NULL];
        _created = attributesDictionary[NSFileCreationDate];
        
        _url = url;
    }
    return self;
}

-(void)download
{
    NSURL *url = [_photoSet.path URLByAppendingPathComponent:[_url lastPathComponent]];
    NSData *photoData = [NSData dataWithContentsOfURL:_url];
    [photoData writeToURL:url atomically:YES];
    _url = url;
}

-(id<XPPhotoCollection>)collection
{
    return _photoSet;
}

-(void)scaleImageToFitSize:(NSSize)size withCompletionBlock:(XPImageCompletionBlock)completionBlock
{
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:_url];
    completionBlock(image);
}

-(NSDictionary *)metadata
{
    NSString *dateAsString = [[[NSDateFormatter alloc] init] stringFromDate:_created];
    return @{@"id": _flickrId, @"title": _title, @"datetaken": dateAsString, @"filename" : [_url lastPathComponent]};
}

-(BOOL)hasLocalCopy
{
    NSURL *url = [_photoSet.path URLByAppendingPathComponent:[_url lastPathComponent]];
    BOOL isDirectory;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDirectory];
    return exists && !isDirectory;
}

-(NSUInteger)hash
{
    return _url.hash;
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    OPFlickrPhoto *otherPhoto = object;
    return [self.url.lastPathComponent isEqual:otherPhoto.url.lastPathComponent];
}

@end
