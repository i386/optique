//
//  OPNewAlbumPanelViewController.h
//  Optique
//
//  Created by James Dumay on 5/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <KBButton/KBButton.h>
#import <KBTextField/KBTextField.h>
#import "OPItemGridView.h"
#import "OPWindowSidebarController.h"

@interface OPNewAlbumPanelViewController : NSViewController<OEGridViewDataSource, OEGridViewDelegate, OPWindowSidebar>

@property (readonly, strong) XPCollectionManager *collectionManager;
@property (weak) IBOutlet OPItemGridView *gridview;
@property (weak) IBOutlet KBTextField *albumNameTextField;
@property (weak) IBOutlet KBButton *doneButton;
@property (weak) id<OPWindowSidebarController> sidebarController;

-initWithCollectionManager:(XPCollectionManager*)collectionManager sidebarController:(id<OPWindowSidebarController>)sidebarController;

@end