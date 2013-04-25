//
//  OPMainWindow.h
//  Optique
//
//  Created by James Dumay on 25/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPWindowContentView.h"

@interface OPMainWindowContentView : OPWindowContentView

@property (weak) NSButton *navigationButton;
@property (assign,) BOOL allowedToShowNavButton;

@end
