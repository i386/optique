//
//  OPDarkroomEditorViewController.h
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPDarkroomPreviewLayer.h"

@interface OPDarkroomPreviewViewController : NSViewController<XPNavigationViewController>

-initWithItem:(id<XPItem>)item sidebarController:(id<XPSidebarController>)sidebarController previewLayer:(OPDarkroomPreviewLayer*)layer;

@end
