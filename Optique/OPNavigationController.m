//
//  OPNavigationController.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "OPNavigationController.h"
#import "OPNavigationBar.h"
#import "OPNavigationViewController.h"

typedef enum OPNavigationControllerAnimationType : NSInteger OPNavigationControllerAnimationType;
enum OPNavigationControllerAnimationType : NSInteger {
    OPNavigationControllerAnimationTypeFirst = 0,
    OPNavigationControllerAnimationTypePopped = 1,
    OPNavigationControllerAnimationTypePushed = 2
};

@interface OPNavigationController () {
    NSMutableArray *_displayStack;
    NSView *_displayView;
    OPNavigationBar *_navigationBar;
}

@property (strong) IBOutlet NSView *displayView;

@property (strong) IBOutlet OPNavigationBar *navigationBar;
@end

@implementation OPNavigationController

-(id)initWithRootViewController:(OPNavigationViewController *)viewController
{
    self = [super initWithNibName:@"OPNavigationController" bundle:nil];
    if (self) {
        _rootViewController = viewController;
        _visibleViewController = viewController;
        _displayStack = [[NSMutableArray alloc] init];
        
        //Setup root controller
        [_displayStack addObject:_rootViewController];
        [_rootViewController setController:self];
        _rootViewController.controller = self;
    }
    
    return self;
}

-(void)pushViewController:(OPNavigationViewController *)viewController
{
    [_displayStack addObject:viewController];
    _visibleViewController.controller = self;
    [self setVisibleViewController:viewController animation:OPNavigationControllerAnimationTypePushed];
}

-(NSArray *)popToRootViewController
{
    if (_displayStack.count > 1)
    {
        [_displayStack removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, _displayStack.count-1)]];
        [self setVisibleViewController:[_displayStack lastObject] animation:OPNavigationControllerAnimationTypePopped];
    }
    return _displayStack;
}

-(NSArray*)popToPreviousViewController
{
    if (_displayStack.count > 1)
    {
        [_displayStack removeLastObject];
        [self setVisibleViewController:[_displayStack lastObject] animation:OPNavigationControllerAnimationTypePopped];
    }
    return _displayStack;
}

-(void)setVisibleViewController:(OPNavigationViewController *)visibleViewController animation:(OPNavigationControllerAnimationType)animationType
{
//    if (animationType != OPNavigationControllerAnimationTypeFirst)
//    {
//        CATransition *transition = [CATransition animation];
//        [transition setType:kCATransitionPush];
//        
//        switch (animationType) {
//            case (OPNavigationControllerAnimationTypePopped):
//                [transition setSubtype:kCATransitionFromRight];
//                break;
//            case (OPNavigationControllerAnimationTypePushed):
//                [transition setSubtype:kCATransitionFromLeft];
//                break;
//            default:
//                break;
//        }
//        
//        NSDictionary *animations = [NSDictionary dictionaryWithObject:transition forKey:@"subviews"];
//        _displayView.animations = animations;
//    }
    
    [_displayView replaceSubview:_visibleViewController.view with:visibleViewController.view];
    _visibleViewController = visibleViewController;
    [_visibleViewController.view setFrame:_displayView.frame];
    [self updateNavigationBarState];
}

-(void)awakeFromNib
{
    NSLog(@"awake");
    [self setVisibleViewController:_rootViewController animation:OPNavigationControllerAnimationTypeFirst];
    [self updateNavigationBarState];
    [_displayView addSubview:_rootViewController.view];
}

-(void)updateNavigationBarState
{
    if (_rootViewController == _visibleViewController)
    {
        [_navigationBar hideBackButton:YES];
    }
    else
    {
        [_navigationBar hideBackButton:NO];
    }
}

@end
