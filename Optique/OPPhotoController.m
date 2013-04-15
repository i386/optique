//
//  OPPhotoController.m
//  Optique
//
//  Created by James Dumay on 15/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoController.h"

@interface OPPhotoController ()

@end

@implementation OPPhotoController

-(id)init
{
    self = [super initWithNibName:@"OPPhotoController" bundle:nil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)setFilter:(CIFilter *)filter
{
    NSLog(@"TODO: reimplement filtering. Filter: %@", filter);
}

@end
