//
//  OPAlbumViewController.m
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAlbumViewController.h"

#import "OPPhotoCollectionViewController.h"

@interface OPAlbumViewController () {
}
@end

@implementation OPAlbumViewController

-(id)initWithPhotoManager:(OPPhotoManager *)photoManager
{
    self = [super initWithNibName:@"OPAlbumViewController" bundle:nil];
    if (self)
    {
        _photoManager = photoManager;
    }
    return self;
}

- (void)doubleClick:(id)sender
{
    OPPhotoAlbum *photoAlbum = [sender representedObject];
    [self.controller pushViewController:[[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:photoAlbum]];
}

-(NSString *)viewTitle
{
    return [NSString stringWithFormat:@"%lu albums", (unsigned long)_photoManager.allAlbums.count];
}

@end
