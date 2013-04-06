//
//  OPPhotoViewController.m
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoViewController.h"
#import "OPPhotoView.h"

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

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)nextPhoto
{
    NSUInteger position = [_photoAlbum.allPhotos indexOfObject:_photo];
    if (position != NSNotFound && position++ < (_photoAlbum.allPhotos.count-1))
    {
        [self changePhoto:position];
    }
}

-(void)previousPhoto
{
    NSUInteger position = [_photoAlbum.allPhotos indexOfObject:_photo];
    if (position != NSNotFound && position != 0 && position-- < _photoAlbum.allPhotos.count)
    {
        [self changePhoto:position];
    }
}

- (IBAction)rotateLeft:(id)sender
{
    [_imageView rotateImageLeft:self];
    [_imageView zoomImageToFit:self];
}

-(void)changePhoto:(NSUInteger)position
{
    _photo = [[_photoAlbum allPhotos] objectAtIndex:position];
    [_imageView setImageWithURL:_photo.path];
    [self.controller updateNavigationBar];
}

@end
