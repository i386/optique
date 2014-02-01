//
//  OPNavigationController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const OPNavigationControllerViewDidChange;

@interface OPNavigationController : NSViewController

@property (strong, readonly) NSViewController *rootViewController;
@property (strong, nonatomic, readonly) NSViewController *visibleViewController;

-initWithRootViewController:(NSViewController*)viewController;

/** forward to new view **/
-(void)pushViewController:(NSViewController *)viewController;

/** back to previous view **/
- (NSArray *)popToPreviousViewController;

/** jump back to the root view **/
- (NSArray *)popToRootViewController;

/** jump back to the root view with no animation **/
- (NSArray *)popToRootViewControllerWithNoAnimation;

- (NSViewController *)peekAtPreviousViewController;

- (bool)isRootViewControllerVisible;

@end
