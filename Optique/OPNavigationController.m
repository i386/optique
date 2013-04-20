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
#import "OPNavigationBar.h"

typedef enum OPNavigationControllerAnimationType : NSInteger OPNavigationControllerAnimationType;
enum OPNavigationControllerAnimationType : NSInteger {
    OPNavigationControllerAnimationTypeFirst = 0,
    OPNavigationControllerAnimationTypePopped = 1,
    OPNavigationControllerAnimationTypePushed = 2
};

@interface OPNavigationController () {
    NSMutableArray *_displayStack;
    NSView *_displayView;
}

@property (strong) IBOutlet NSView *displayView;

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
    viewController.controller = self;
    [self setVisibleViewController:viewController animation:OPNavigationControllerAnimationTypePushed];
}

-(NSArray *)popToRootViewController
{
    if (_displayStack.count > 1)
    {
        [_displayStack removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, _displayStack.count-1)]];
        [self setVisibleViewController:[_displayStack lastObject] animation:OPNavigationControllerAnimationTypePopped];
    }
    return [NSArray arrayWithArray:_displayStack];
}

-(NSArray*)popToPreviousViewController
{
    if (_displayStack.count > 1)
    {
        [_displayStack removeLastObject];
        [self setVisibleViewController:[_displayStack lastObject] animation:OPNavigationControllerAnimationTypePopped];
    }
    return [NSArray arrayWithArray:_displayStack];
}

-(void)updateNavigationBar
{
    if (_rootViewController == _visibleViewController)
    {
        [_navigationBar hideBackButton:YES];
    }
    else
    {
        [_navigationBar hideBackButton:NO];
    }
    
    [_navigationBar updateTitle:_visibleViewController.viewTitle];
}

-(void)setVisibleViewController:(OPNavigationViewController *)visibleViewController animation:(OPNavigationControllerAnimationType)animationType
{
    if (animationType != OPNavigationControllerAnimationTypeFirst)
    {
        CATransition *transition = [CATransition animation];
        [transition setType:kCATransitionPush];
        
        switch (animationType) {
            case (OPNavigationControllerAnimationTypePopped):
                [transition setSubtype:kCATransitionFromLeft];
                break;
            case (OPNavigationControllerAnimationTypePushed):
                [transition setSubtype:kCATransitionFromRight];
                break;
            default:
                break;
        }
        
        [transition setDuration:0.3];
        
        [_displayView setAnimations:[NSDictionary dictionaryWithObject:transition forKey:@"subviews"]];
    }

    [visibleViewController.view setFrame:_displayView.frame];
    [_displayView.animator replaceSubview:_visibleViewController.view with:visibleViewController.view];
    _visibleViewController = visibleViewController;
    
    //Make visible view first responder
    [_visibleViewController.view.window makeFirstResponder:_visibleViewController.view];
    
    [self updateNavigationBar];
    [_visibleViewController showView];
}

-(void)awakeFromNib
{
    [self setVisibleViewController:_rootViewController animation:OPNavigationControllerAnimationTypeFirst];
    [self updateNavigationBar];
    [_displayView addSubview:_rootViewController.view];
}

@end
