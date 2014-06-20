//
//  OPNewAlbumPanelViewController.h
//  Optique
//
//  Created by James Dumay on 5/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <KBTextField/KBTextField.h>
#import "OPItemGridView.h"

@interface OPNewAlbumPanelViewController : NSViewController<OEGridViewDataSource, OEGridViewDelegate, XPSidebar>

@property (readonly, strong) XPCollectionManager *collectionManager;
@property (weak) IBOutlet OPItemGridView *gridview;
@property (weak) IBOutlet KBTextField *albumNameTextField;
@property (weak) IBOutlet NSButton *doneButton;
@property (weak) id<XPSidebarController> sidebarController;

-initWithCollectionManager:(XPCollectionManager*)collectionManager sidebarController:(id<XPSidebarController>)sidebarController;

@end