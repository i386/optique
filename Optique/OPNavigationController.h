//
//  OPNavigationController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const OPNavigationControllerViewDidChange;

@interface OPNavigationController : NSViewController <XPNavigationController>

@property (strong, readonly) NSViewController *rootViewController;
@property (strong, nonatomic, readonly) NSViewController *visibleViewController;
@property (readonly, getter = isRootViewControllerVisible) BOOL rootViewControllerVisible;

-initWithRootViewController:(NSViewController*)viewController;

/** 
 push a new view on the stack
 */
-(void)pushViewController:(NSViewController *)viewController;

/** 
 pop back to previous view
 */
- (NSArray *)popToPreviousViewController;

/** 
 Jump back to the root view 
 */
- (NSArray *)popToRootViewController;

/** 
 Jump back to the root view with no animation
 */
- (NSArray *)popToRootViewControllerWithNoAnimation;

/**
 The view controller behind the visible controller
 */
- (NSViewController *)peekAtPreviousViewController;

@end
