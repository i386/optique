//
//  OPWindowSidebar.h
//  Optique
//
//  Created by James Dumay on 5/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 Controls the sidebar on the main window that is commonly used for creating new albums, etc
 */
@protocol XPSidebarController <NSObject>

-(void)showSidebarWithViewController:(NSViewController*)viewController;

-(void)hideSidebar;

@end

@protocol XPSidebar

@optional

-(void)activate;

-(void)closed;

@end
