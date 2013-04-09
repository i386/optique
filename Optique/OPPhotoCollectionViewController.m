//
//  OPPhotoCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoCollectionViewController.h"
#import "OPPhotoViewController.h"
#import "OPPhotoGridItemView.h"
#import "CNGridViewItemLayout.h"
#import "OPPhotoGridView.h"
#import "OPImagePreviewService.h"
#import "OPPhotoManager.h"

@interface OPPhotoCollectionViewController ()

@end

@implementation OPPhotoCollectionViewController

-(id)initWithPhotoAlbum:(OPPhotoAlbum *)photoAlbum
{
    self = [super initWithNibName:@"OPPhotoCollectionViewController" bundle:nil];
    if (self)
    {
        _photoAlbum = photoAlbum;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumUpdated:) name:OPPhotoManagerDidUpdateAlbum object:nil];
    }
    
    return self;
}

- (IBAction)revealInFinder:(NSMenuItem*)sender
{
    NSNumber *index = (NSNumber*)sender.representedObject;
    OPPhoto *photo = _photoAlbum.allPhotos[index.unsignedIntValue];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[photo.path]];
}

-(NSString *)viewTitle
{
    return _photoAlbum.title;
}

- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    OPPhotoViewController *photoViewContoller = [[OPPhotoViewController alloc] initWithPhotoAlbum:_photoAlbum photo:_photoAlbum.allPhotos[index]];
    [self.controller pushViewController:photoViewContoller];
}

- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    return _photoAlbum.allPhotos.count;
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section
{
    OPPhotoGridItemView *item = [gridView dequeueReusableItemWithIdentifier:(NSString*)OPPhotoGridViewReuseIdentifier];
    if (item == nil) {
        item = [[OPPhotoGridItemView alloc] initWithLayout:nil reuseIdentifier:(NSString*)OPPhotoGridViewReuseIdentifier];
    }
    
    NSArray *allPhotos = [_photoAlbum.allPhotos copy];
    
    if (allPhotos.count > 0)
    {
        OPPhoto *photo = allPhotos[index];
        item.itemImage = [[OPImagePreviewService defaultService] previewImageAtURL:photo.path loaded:^(NSImage *image) {
            [self performOnMainThreadWithBlock:^{
                [_gridView redrawItemAtIndex:index];
            }];
        }];
        
        item.itemTitle = photo.title;
    }
    
    return item;
}

-(void)albumUpdated:(NSNotification*)notification
{
    [self performOnMainThreadWithBlock:^{
        [_gridView reloadDataAnimated:YES];
    }];
}

-(void)loadView
{
    [super loadView];
    
    [_gridView reloadData];
}

@end
