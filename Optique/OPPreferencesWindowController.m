//
//  OPPreferencesWindowController.m
//  Optique
//
//  Created by James Dumay on 27/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPPreferencesWindowController.h"
#import "OPGeneralPreferencesViewController.h"

@interface OPPreferencesWindowController ()

@end

@implementation OPPreferencesWindowController

-(id)init
{
    self = [super initWithViewControllers:@[]];
    if (self)
    {
        OPGeneralPreferencesViewController *viewController = [[OPGeneralPreferencesViewController alloc] init];
        [self addViewController:viewController];
        
        [[XPExposureService preferencePanelViewControllers] bk_each:^(id obj) {
            [self addViewController:obj];
        }];
    }
    return self;
}

@end
