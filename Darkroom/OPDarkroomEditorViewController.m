//
//  OPDarkroomEditorViewController.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPDarkroomEditorViewController.h"

@interface OPDarkroomEditorViewController ()

@end

@implementation OPDarkroomEditorViewController

- (id)init
{
    NSBundle *thisBundle = [NSBundle bundleForClass:[OPDarkroomEditorViewController class]];
    self = [super initWithNibName:@"OPDarkroomEditorViewController" bundle:thisBundle];
    if (self) {
        // Initialization code here.
    }
    return self;
}

@end
