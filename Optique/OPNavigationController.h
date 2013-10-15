//
//  OPNavigationController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OPNavigationTitle;
@class OPNavigationViewController;

extern NSString *const OPNavigationControllerViewDidChange;

@interface OPNavigationController : NSViewController

@property (strong, readonly) OPNavigationViewController *rootViewController;
@property (strong, nonatomic, readonly) OPNavigationViewController *visibleViewController;
@property (strong) IBOutlet OPNavigationTitle *navigationTitle;

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

- (bool)isRootViewControllerVisible;

@end
