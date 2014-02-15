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
#import "OPDarkroomPreviewLayer.h"

#define DarkroomToolbarIdentifier   @"darkroom-edit"

@interface OPDarkroomPlugin ()

@property (strong) OPDarkroomPreviewViewController *darkroomPreviewViewController;
@property (strong) OPDarkroomEditorPanelViewController *darkroomEditorPanelController;

@end

@implementation OPDarkroomPlugin

-(NSToolbarItem*)toolbarItemForIdentifier:(NSString*)identifier
{
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
            OPDarkroomPreviewLayer *layer = [[OPDarkroomPreviewLayer alloc] init];
            
            _editManager = [[OPDarkroomEditManager alloc] initWithItem:item previewLayer:layer];
            
            _darkroomPreviewViewController = [[OPDarkroomPreviewViewController alloc] initWithItem:item sidebarController:_sidebarController previewLayer:layer];
            _darkroomEditorPanelController = [[OPDarkroomEditorPanelViewController alloc] initWithEditManager:_editManager item:item];
            
            [_navigationController pushViewController:_darkroomPreviewViewController];
            [_sidebarController showSidebarWithViewController:_darkroomEditorPanelController];
        }
    }
}

@end
