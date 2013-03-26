//
//  OPPhotoAlbumViewController.m
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoAlbumViewController.h"

@interface OPPhotoAlbumViewController ()

@end

@implementation OPPhotoAlbumViewController

-(id)initWithPhotoManager:(OPPhotoManager *)photoManager album:(OPPhotoAlbum *)album
{
    self = [super initWithNibName:@"OPPhotoAlbumViewController" bundle:nil];
    if (self)
    {
        _photoManager = photoManager;
        _photoAlbum = album;
    }
    return self;
}

@end
