//
//  OPNavigationController.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "OPNavigationController.h"
#import "OPNavigationViewController.h"

NSString *const OPNavigationControllerViewDidChange = @"OPNavigationControllerViewDidChange";

@interface OPNavigationController ()

@property (strong) IBOutlet NSView *displayView;
@property (strong) NSMutableArray *displayStack;

@end

@implementation OPNavigationController

-(id)initWithRootViewController:(NSViewController *)viewController
{
    self = [super initWithNibName:@"OPNavigationController" bundle:nil];
    if (self)
    {
        _rootViewController = viewController;
        _visibleViewController = viewController;
        _displayStack = [[NSMutableArray alloc] init];
        
        //Setup root controller
        [_displayStack addObject:_rootViewController];
        
        if ([viewController isKindOfClass:[OPNavigationViewController class]])
        {
            ((OPNavigationViewController*)viewController).controller = self;
        }
    }
    
    return self;
}

-(void)pushViewController:(NSViewController *)viewController
{
    [_displayStack addObject:viewController];
    if ([viewController isKindOfClass:[OPNavigationViewController class]])
    {
        ((OPNavigationViewController*)viewController).controller = self;
    }
    [self setVisibleViewController:viewController animate:YES];
}

-(NSArray *)popToRootViewController
{
    return [self popToRootViewControllerWithAnimation:YES];
}

-(NSArray *)popToRootViewControllerWithNoAnimation
{
    return [self popToRootViewControllerWithAnimation:NO];
}

-(NSArray*)popToPreviousViewController
{
    if (_displayStack.count > 1)
    {
        [_displayStack removeLastObject];
        [self setVisibleViewController:[_displayStack lastObject] animate:YES];
    }
    return [NSArray arrayWithArray:_displayStack];
}

-(OPNavigationViewController *)peekAtPreviousViewController
{
    if (_displayStack.count > 1)
    {
        return _displayStack[_displayStack.count-2];
    }
    return nil;
}

-(bool)isRootViewControllerVisible
{
    return [self.rootViewController isEqual:_visibleViewController];
}

-(NSArray *)popToRootViewControllerWithAnimation:(BOOL)animate
{
    if (_displayStack.count > 1)
    {
        [_displayStack removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, _displayStack.count-1)]];
        [self setVisibleViewController:[_displayStack lastObject] animate:animate];
    }
    return [NSArray arrayWithArray:_displayStack];
}

-(void)setVisibleViewController:(NSViewController *)visibleViewController animate:(BOOL)animate
{
    if (animate)
    {
        CATransition *transition = [CATransition animation];
        [transition setType:kCATransitionFade];
        [transition setDuration:0.3];
        [_displayView setAnimations:@{@"subviews": transition}];
    }
    else
    {
        [_displayView setAnimations:nil];
    }

    [visibleViewController.view setFrame:_displayView.frame];
    [_displayView.animator replaceSubview:_visibleViewController.view with:visibleViewController.view];
    
    if ([_visibleViewController isKindOfClass:[OPNavigationViewController class]])
    {
        [((OPNavigationViewController*)_visibleViewController) removedView];
    }
    
    _visibleViewController = visibleViewController;
    
    //Make visible view first responder
    [_visibleViewController.view.window makeFirstResponder:_visibleViewController.view];
    
    if ([_visibleViewController isKindOfClass:[OPNavigationViewController class]])
    {
        [((OPNavigationViewController*)_visibleViewController) showView];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OPNavigationControllerViewDidChange object:self userInfo:@{@"controller": _visibleViewController}];
}

-(void)awakeFromNib
{
    [self setVisibleViewController:_rootViewController animate:NO];
    
    [_displayView addSubview:_rootViewController.view];
}

@end
