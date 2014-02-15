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

-initWithEditManager:(OPDarkroomEditManager*)editManager item:(id<XPItem>)item
{
    NSBundle *thisBundle = [NSBundle bundleForClass:[OPDarkroomEditorPanelViewController class]];
    self = [super initWithNibName:@"OPDarkroomEditorPanelViewController" bundle:thisBundle];
    if (self) {
        _editManager = editManager;
        _item = item;
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [_saveButton setKBButtonType:BButtonTypePrimary];
}

-(BOOL)isReadOnly
{
    return [OPDarkroomEditManager IsWritableInNativeFormat:_item];
}

-(BOOL)isSaveAvailable
{
    return ![self isReadOnly] && _editManager.count;
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
