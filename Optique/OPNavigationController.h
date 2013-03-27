//
//  OPNavigationController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "OPNavigationViewController.h"

@class OPNavigationViewController;

@interface OPNavigationController : NSViewController

@property (strong, readonly) OPNavigationViewController *rootViewController;
@property (strong, nonatomic, readonly) OPNavigationViewController *visibleViewController;

-initWithRootViewController:(OPNavigationViewController*)viewController;

-(void)pushViewController:(OPNavigationViewController *)viewController;

- (NSArray *)popToPreviousViewController;

- (NSArray *)popToRootViewController;

@end
