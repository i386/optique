//
//  OPGridView.h
//  Optique
//
//  Created by James Dumay on 14/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPGridView.h"

@class OPCollectionViewController;

@interface OPCollectionGridView : OPGridView

@property (weak) IBOutlet OPCollectionViewController *controller;

-(void)copy:(id)sender;

@end
