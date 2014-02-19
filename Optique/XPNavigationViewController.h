//
//  XPNavigationViewController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol XPNavigationViewController <NSObject>

@optional

@property (weak) id<XPNavigationController> controller;

/**
 Called with the `OPNavigationController` displays the view when the controller is made visible initially or is popped.
 */
-(void)showView;

-(void)removedView;

@end
