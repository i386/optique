//
//  OPDarkroomEditorPanelViewController.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPDarkroomEditorPanelViewController.h"
#import "OPRotateEditOperation.h"
#import <KBButton/KBButton.h>

@interface OPDarkroomEditorPanelViewController ()

@property (weak) id<XPItem> item;
@property (weak) OPDarkroomEditManager *editManager;
@property (weak) IBOutlet KBButton *saveButton;

@end

@implementation OPDarkroomEditorPanelViewController

-initWithEditManager:(OPDarkroomEditManager*)editManager;
{
    NSBundle *thisBundle = [NSBundle bundleForClass:[OPDarkroomEditorPanelViewController class]];
    self = [super initWithNibName:@"OPDarkroomEditorPanelViewController" bundle:thisBundle];
    if (self) {
        _editManager = editManager;
    }
    return self;
}

- (IBAction)rotate:(id)sender
{
    OPRotateEditOperation *operation = [[OPRotateEditOperation alloc] init];
    [_editManager addOperation:operation];
}

- (IBAction)save:(id)sender
{
}

@end
