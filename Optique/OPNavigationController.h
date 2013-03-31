//
//  OPNavigationController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OPNavigationBar;

@class OPNavigationViewController;

@interface OPNavigationController : NSViewController

@property (strong, readonly) OPNavigationViewController *rootViewController;
@property (strong, nonatomic, readonly) OPNavigationViewController *visibleViewController;
@property (strong) IBOutlet OPNavigationBar *navigationBar;

-initWithRootViewController:(OPNavigationViewController*)viewController;

/** forward to new view **/
-(void)pushViewController:(OPNavigationViewController *)viewController;

/** back to previous view **/
- (NSArray *)popToPreviousViewController;

/** jump back to the root view **/
- (NSArray *)popToRootViewController;

/** update the state of the navigation bar for the visible view **/
- (void)updateNavigationBar;

@end
