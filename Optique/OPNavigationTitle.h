//
//  OPNavigationBar.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPNavigationController.h"

extern NSString *const OPNavigationTitleFilterDidChange;
extern NSString *const OPNavigationSearchFilterDidChange;

typedef enum {
    OPNavigationTitleFilterAlbums = 0,
    OPNavigationTitleFilterDevices = 1,
} OPNavigationTitleFilter;

@interface OPNavigationTitle : NSView<NSMenuDelegate> {
    IBOutlet NSTextField *_viewLabel;
    IBOutlet OPNavigationController *_navigationController;
}

@property (assign) BOOL isAlbums;
@property (strong) IBOutlet NSButton *shareWithButton;
@property (strong) IBOutlet NSButton *switchViewButton;
@property (strong) IBOutlet NSSearchField *searchFilter;

- (void)updateTitle:(NSString*)label;

- (IBAction)goBack:(id)sender;
- (IBAction)switchViewButtonPressed:(id)sender;

@end
