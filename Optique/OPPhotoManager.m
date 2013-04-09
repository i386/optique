//
//  OPPhotoManager.m
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoManager.h"
#import "OPPhotoAlbum.h"
#import "OPAlbumScanner.h"

NSString *const OPPhotoManagerDidAddAlbum = @"OPPhotoManagerDidAddAlbum";
NSString *const OPPhotoManagerDidUpdateAlbum = @"OPPhotoManagerDidUpdateAlbum";

@implementation OPPhotoManager

-(id)initWithPath:(NSURL *)path
{
    self = [super init];
    if (self)
    {
        _path = path;
        _allAlbums = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foundAlbum:) name:OPAlbumScannerDidFindAlbumNotification object:nil];
    }
    return self;
}

-(void)foundAlbum:(NSNotification*)event
{
    NSDictionary *userInfo = event.userInfo;
    OPPhotoAlbum *album = userInfo[@"album"];
    OPPhotoManager *photoManager = userInfo[@"photoManager"];
    
    //Return if photo manager does not match
    if (photoManager == self)
    {
        NSMutableArray *albums = (NSMutableArray*)_allAlbums;
        if (![albums containsObject:album])
        {
            [albums addObject:album];
            [[NSNotificationCenter defaultCenter] postNotificationName:OPPhotoManagerDidAddAlbum object:nil userInfo:@{@"album": album, @"photoManager": self}];
        }
        else
        {
            for (OPPhotoAlbum *existingAlbum in _allAlbums)
            {
                if ([existingAlbum isEqual:album])
                {
                    [existingAlbum reloadPhotos];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:OPPhotoManagerDidUpdateAlbum object:nil userInfo:@{@"album": existingAlbum, @"photoManager": self}];
                    
                    break;
                }
            }
        }
    }
}

@end
