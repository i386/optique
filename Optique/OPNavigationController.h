//
//  OPNavigationController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPNavigationControllerDelegate.h"

@class OPNavigationTitle;
@class OPNavigationViewController;

extern NSString *const OPNavigationControllerViewDidChange;

@interface OPNavigationController : NSViewController

@property (strong, readonly) OPNavigationViewController *rootViewController;
@property (strong, nonatomic, readonly) OPNavigationViewController *visibleViewController;
@property (strong) IBOutlet OPNavigationTitle *navigationTitle;
@property (strong) IBOutlet id<OPNavigationControllerDelegate> delegate;

-initWithRootViewController:(OPNavigationViewController*)viewController;

/** forward to new view **/
-(void)pushViewController:(OPNavigationViewController *)viewController;

/** back to previous view **/
- (NSArray *)popToPreviousViewController;

/** jump back to the root view **/
- (NSArray *)popToRootViewController;

/** jump back to the root view with no animation **/
- (NSArray *)popToRootViewControllerWithNoAnimation;

- (OPNavigationViewController *)peekAtPreviousViewController;

/** update the state of the navigation for the visible view controller **/
- (void)updateNavigation;

@end
