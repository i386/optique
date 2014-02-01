//
//  OPDarkroomPlugin.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPDarkroomPlugin.h"
#import "OPDarkroomEditorViewController.h"
#import "OPDarkroomEditorPanelViewController.h"

#define DarkroomToolbarIdentifier   @"darkroom-edit"

@interface OPDarkroomPlugin ()

@property (strong) OPDarkroomEditorViewController *darkroomEditorController;
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
    _darkroomEditorController = [[OPDarkroomEditorViewController alloc] init];
    _darkroomEditorPanelController = [[OPDarkroomEditorPanelViewController alloc] init];
    
    [_navigationController pushViewController:_darkroomEditorController];
    [_sidebarController showSidebarWithViewController:_darkroomEditorPanelController];
}

@end
