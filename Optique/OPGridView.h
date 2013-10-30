//
//  OPGridView.h
//  Optique
//
//  Created by James Dumay on 14/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OEGridView/OEGridView.h>

@class OPCollectionViewController;

@interface OPGridView : OEGridView

@property (weak) IBOutlet OPCollectionViewController *controller;

-(void)copy:(id)sender;

@end
