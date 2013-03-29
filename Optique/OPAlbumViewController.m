//
//  OPAlbumViewController.m
//  Optique
//
//  Created by James Dumay on 24/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAlbumViewController.h"

#import "OPPhotoCollectionViewController.h"
#import "OPPhotoManager.h"

@interface OPAlbumViewController () {
}
@end

@implementation OPAlbumViewController

-(id)initWithPhotoManager:(OPPhotoManager *)photoManager
{
    self = [super initWithNibName:@"OPAlbumViewController" bundle:nil];
    if (self)
    {
        _albums = [[NSMutableArray alloc] init];
        _photoManager = photoManager;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumAdded:) name:OPPhotoManagerDidAddAlbum object:nil];
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
    return [NSString stringWithFormat:@"%lu albums", (unsigned long)_albums.count];
}

-(void)albumAdded:(NSNotification*)notification
{
    OPPhotoAlbum *album = [notification userInfo][@"album"];
    if (album)
    {
        [self performSelectorOnMainThread:@selector(updateAlbums:) withObject:album waitUntilDone:NO];
    }
}

-(void)updateAlbums:(OPPhotoAlbum*)album
{
    if (album)
    {
        [self willChangeValueForKey:@"self.albums"];
        
        [_albumArrayController addObject:album];
        
        [self didChangeValueForKey:@"self.albums"];
        
        [self.controller updateNavigationBar];
    }
}

@end
