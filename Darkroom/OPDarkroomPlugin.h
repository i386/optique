//
//  OPDarkroomPlugin.h
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPDarkroomPlugin : NSObject<XPToolbarItemProvider>

@property (weak) id<XPNavigationController> navigationController;
@property (weak) id<XPSidebarController> sidebarController;

@end
