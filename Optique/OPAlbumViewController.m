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
    if (self) {
        _photoManager = photoManager;
    }
    return self;
}

-(void)awakeFromNib
{
    [_collectionView setSelectable:YES];
    
    [_collectionView addObserver:self forKeyPath:@"selectionIndexes"
                     options:NSKeyValueObservingOptionNew context:NULL];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectionIndexes"])
    {
        NSIndexSet *indexSet = change[@"new"];
        if (indexSet)
        {
            NSInteger index = [indexSet firstIndex];
            OPPhotoAlbum *album = [[_collectionView itemAtIndex:index] representedObject];
//            NSLog(@"%@", album.title);
        }
    }
}

- (void)doubleClick:(id)sender
{
    OPPhotoAlbum *photoAlbum = [sender representedObject];
    [self.controller pushViewController:[[OPPhotoCollectionViewController alloc] initWithPhotoAlbum:photoAlbum]];
}

@end
