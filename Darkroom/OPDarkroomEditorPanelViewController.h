//
//  OPDarkroomEditorPanelViewController.h
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPDarkroomManager.h"

@interface OPDarkroomEditorPanelViewController : NSViewController<XPSidebar>

@property (readonly, nonatomic, getter = isReadOnly) BOOL readOnly;
@property (readonly, nonatomic, getter = isSaveAvailable) BOOL saveAvailable;

-initWithEditManager:(OPDarkroomManager*)editManager item:(id<XPItem>)item navigationController:(id<XPNavigationController>)navigationController sidebarController:(id<XPSidebarController>)sidebarController;

@end
