//
//  OPNavigationViewController.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPNavigationController.h"

@interface OPNavigationViewController : NSViewController

@property (weak) OPNavigationController *controller;

/**
 The calculated title for the view to show in the `OPNavigationBar`.
 */ 
-(NSString*)viewTitle;

/**
 Called with the `OPNavigationController` displays the view when the controller is made visible initially or is popped.
 */
-(void)showView;

@end
