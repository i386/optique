//
//  OPDarkroomPlugin.h
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPDarkroomEditManager.h"

@interface OPDarkroomPlugin : NSObject<
#if DEBUG
XPToolbarItemProvider
#endif
>

@property (weak, nonatomic) id<XPNavigationController> navigationController;
@property (weak, nonatomic) id<XPSidebarController> sidebarController;
@property (strong) OPDarkroomEditManager *editManager;

@end
