//
//  OPDarkroomEditorPanelViewController.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPDarkroomEditorPanelViewController.h"
#import "OPRotateEditOperation.h"
#import "OPRedEyeCorrectionOperation.h"
#import "OPAutoAdjustEnhanceOperation.h"

@interface OPDarkroomEditorPanelViewController ()

@property (weak) id<XPItem> item;
@property (weak) OPDarkroomManager *editManager;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) id<XPNavigationController> navigationController;
@property (weak) id<XPSidebarController> sidebarController;

@end

@implementation OPDarkroomEditorPanelViewController


-(id)initWithEditManager:(OPDarkroomManager *)editManager item:(id<XPItem>)item navigationController:(id<XPNavigationController>)navigationController sidebarController:(id<XPSidebarController>)sidebarController
{
    NSBundle *thisBundle = [NSBundle bundleForClass:[OPDarkroomEditorPanelViewController class]];
    self = [super initWithNibName:@"OPDarkroomEditorPanelViewController" bundle:thisBundle];
    if (self) {
        _editManager = editManager;
        _item = item;
        _navigationController = navigationController;
        _sidebarController = sidebarController;
    }
    return self;
}

-(BOOL)isReadOnly
{
    return ![OPDarkroomManager IsWritableInNativeFormat:_item];
}

-(BOOL)isSaveAvailable
{
    return ![self isReadOnly] && _editManager.count > 0;
}

- (IBAction)rotate:(id)sender
{
    OPRotateEditOperation *operation = [[OPRotateEditOperation alloc] init];
    [self addOperation:operation];
}

- (IBAction)fixRedEye:(id)sender
{
    OPRedEyeCorrectionOperation *operation = [[OPRedEyeCorrectionOperation alloc] init];
    [self addOperation:operation];
}

- (IBAction)autoenhance:(id)sender
{
    OPAutoAdjustEnhanceOperation *operation = [[OPAutoAdjustEnhanceOperation alloc] init];
    [self addOperation:operation];
}

- (IBAction)save:(id)sender
{
    [_editManager commit];
    [_sidebarController hideSidebar];
    [_navigationController popToPreviousViewController];
}

- (void)addOperation:(id<OPDarkroomOperation>)operation
{
    [self willChangeValueForKey:@"saveAvailable"];
    [_editManager addOperation:operation];
    [self didChangeValueForKey:@"saveAvailable"];
}

@end
