//
//  OPPhotoView.h
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class OPPItemViewController;

@interface OPItemView : NSView

@property (weak) IBOutlet OPPItemViewController *controller;

-(void)copy:(id)sender;

@end
