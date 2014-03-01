//
//  OPCameraPreferencesViewController.m
//  Optique
//
//  Created by James Dumay on 1/03/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPCameraPreferencesViewController.h"

@interface OPCameraPreferencesViewController ()

@end

@implementation OPCameraPreferencesViewController

- (id)init
{
    NSBundle *thisBundle = [NSBundle bundleForClass:[OPCameraPreferencesViewController class]];
    self = [super initWithNibName:@"OPCameraPreferencesViewController" bundle:thisBundle];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(NSString *)identifier
{
    return @"camera";
}

-(NSString *)toolbarItemLabel
{
    return @"Cameras";
}

-(NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

@end
