//
//  OPCameraCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 20/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraCollectionViewController.h"
#import "OPCameraPhotoCollectionViewController.h"

@interface OPCameraCollectionViewController ()

@end

@implementation OPCameraCollectionViewController

-(OPNavigationViewController *)viewForCollection:(id<XPItemCollection>)collection collectionManager:(XPCollectionManager *)collectionManager
{
    return [[OPCameraPhotoCollectionViewController alloc] initWithPhotoAlbum:collection collectionManager:collectionManager];
}

@end
