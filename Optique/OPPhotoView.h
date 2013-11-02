//
//  OPPhotoView.h
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class OPPhotoViewController;

@interface OPPhotoView : NSView

@property (weak) IBOutlet OPPhotoViewController *controller;

-(void)copy:(id)sender;

-(void)rotateLeft:(id)sender;

@end
