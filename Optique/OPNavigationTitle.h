//
//  OPNavigationBar.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "OPNavigationController.h"

@interface OPNavigationTitle : NSView {
    IBOutlet NSTextField *_viewLabel;
    IBOutlet NSButton *shareButton;
    IBOutlet NSSegmentedControl *filterSegmentedControl;
    IBOutlet OPNavigationController *_navigationController;
}

-(void)updateTitle:(NSString*)label;

- (IBAction)filterSegmentChanged:(id)sender;

@end
