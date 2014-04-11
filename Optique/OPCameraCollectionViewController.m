//
//  OPCameraCollectionViewController.m
//  Optique
//
//  Created by James Dumay on 20/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraCollectionViewController.h"
#import "OPCameraItemCollectionViewController.h"

@interface OPCameraCollectionViewController ()

@end

@implementation OPCameraCollectionViewController


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.gridView.clickingBackgroundDeselectsAllCells = NO;
}

-(NSViewController *)viewForCollection:(id<XPItemCollection>)collection collectionManager:(XPCollectionManager *)collectionManager
{
    return [[OPCameraItemCollectionViewController alloc] initWithIemCollection:collection collectionManager:collectionManager];
}

@end
