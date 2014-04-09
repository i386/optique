//
//  XPNavigationController.h
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XPNavigationController <NSObject>

@property (strong, readonly) NSViewController *rootViewController;
@property (strong, nonatomic, readonly) NSViewController *visibleViewController;
@property (readonly, getter = isRootViewControllerVisible) BOOL rootViewControllerVisible;

/** forward to new view **/
-(void)pushViewController:(NSViewController *)viewController;

/** back to previous view **/
- (NSArray *)popToPreviousViewController;

/** jump back to the root view **/
- (NSArray *)popToRootViewController;

/** jump back to the root view with no animation **/
- (NSArray *)popToRootViewControllerWithNoAnimation;

- (NSViewController *)peekAtPreviousViewController;

@end
