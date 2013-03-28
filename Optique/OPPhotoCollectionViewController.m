//
//  OPPhotoCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoCollectionViewController.h"

@interface OPPhotoCollectionViewController ()

@end

@implementation OPPhotoCollectionViewController

-(id)initWithPhotoAlbum:(OPPhotoAlbum *)photoAlbum
{
    self = [super initWithNibName:@"OPPhotoCollectionViewController" bundle:nil];
    if (self) {
        _photoAlbum = photoAlbum;
    }
    
    return self;
}

-(NSString *)viewTitle
{
    return _photoAlbum.title;
}

- (void)doubleClick:(id)sender
{
    NSLog(@"doubleclicked");
}

@end
