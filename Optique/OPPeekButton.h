//
//  OPPeekButton.h
//  Optique
//
//  Created by James Dumay on 4/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPHistoryPeekViewController.h"

@interface OPPeekButton : NSButton

@property (assign) OPHistoryPeekViewController *historyPeekViewController;
@property (assign) BOOL peek;

@end
