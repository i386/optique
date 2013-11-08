//
//  OPNewsletterWindowController.h
//  Optique
//
//  Created by James Dumay on 5/11/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <KBButton/KBButton.h>

@interface OPNewsletterWindowController : NSWindowController

@property (weak) IBOutlet KBButton *subscribeButton;
@property (weak) IBOutlet KBButton *cancelButton;

@end
