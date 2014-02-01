//
//  OPDarkroomEditorPanelViewController.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPDarkroomEditorPanelViewController.h"

@interface OPDarkroomEditorPanelViewController ()

@end

@implementation OPDarkroomEditorPanelViewController

- (id)init
{
    NSBundle *thisBundle = [NSBundle bundleForClass:[OPDarkroomEditorPanelViewController class]];
    self = [super initWithNibName:@"OPDarkroomEditorPanelViewController" bundle:thisBundle];
    if (self) {
        // Initialization code here.
    }
    return self;
}

@end
