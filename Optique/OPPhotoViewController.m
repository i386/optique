//
//  OPPhotoViewController.m
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoViewController.h"

@interface OPPhotoViewController ()

@end

@implementation OPPhotoViewController

-(id)initWithPhotoAlbum:(OPPhotoAlbum *)album photo:(OPPhoto *)photo
{
    self = [super initWithNibName:@"OPPhotoViewController" bundle:nil];
    if (self) {
        _photoAlbum = album;
        _photo = photo;
    }
    return self;
}

-(NSString *)viewTitle
{
    return [[[self.photo.path path] lastPathComponent] stringByDeletingPathExtension];
}

@end
