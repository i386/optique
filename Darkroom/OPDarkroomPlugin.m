//
//  OPDarkroomPlugin.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPDarkroomPlugin.h"
#import "OPDarkroomPreviewViewController.h"
#import "OPDarkroomEditorPanelViewController.h"
#import "OPRotateOperationOptimizer.h"

#define DarkroomToolbarIdentifier   @"darkroom-edit"

@interface OPDarkroomPlugin ()

@property (strong) OPDarkroomPreviewViewController *darkroomPreviewViewController;
@property (strong) OPDarkroomEditorPanelViewController *darkroomEditorPanelController;

@end

@implementation OPDarkroomPlugin

-(NSToolbarItem*)toolbarItemForIdentifier:(NSString*)identifier
{
    #if DEBUG
    if ([DarkroomToolbarIdentifier isEqualToString:identifier])
    {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        item.label = @"Edit";
        item.image = [NSImage imageNamed:NSImageNameQuickLookTemplate];
        
        NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 72, 32)];
        item.view = button;
        button.image = item.image;
        button.title = item.label;
        button.bezelStyle = NSTexturedRoundedBezelStyle;
        button.target = self;
        button.action = @selector(openDarkroomEditor);  
        return item;
    }
    #endif
    return nil;
}

-(void)addToolbarItemsForToolbar:(NSToolbar*)toolbar
{
    [toolbar insertItemWithItemIdentifier:DarkroomToolbarIdentifier atIndex:3];
}

-(void)openDarkroomEditor
{
    if ([[_navigationController visibleViewController] conformsToProtocol:@protocol(XPItemController)])
    {
        id<XPItemController> controller = (id<XPItemController>)[_navigationController visibleViewController];
        id<XPItem> item = [controller item];
        if ([item type] == XPItemTypePhoto)
        {
            _editManager = [[OPDarkroomManager alloc] initWithItem:item previewLayer:[controller imageLayer]];
            
            //Register optimisers
            [_editManager addOptimizer:[OPRotateOperationOptimizer alloc]];
            
            _darkroomPreviewViewController = [[OPDarkroomPreviewViewController alloc] initWithItem:item sidebarController:_sidebarController previewLayer:[controller imageLayer]];
            _darkroomEditorPanelController = [[OPDarkroomEditorPanelViewController alloc] initWithEditManager:_editManager item:item navigationController:_navigationController sidebarController:_sidebarController];
            
            [_navigationController pushViewController:_darkroomPreviewViewController];
            [_sidebarController showSidebarWithViewController:_darkroomEditorPanelController];
        }
    }
}

@end
