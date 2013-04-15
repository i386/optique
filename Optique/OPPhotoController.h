//
//  OPPhotoController.h
//  Optique
//
//  Created by James Dumay on 15/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OPPhotoController : NSViewController

@property (strong) IBOutlet NSImageView *imageView;
@property (strong) IBOutlet NSMenu *contextMenu;

-(void)setFilter:(CIFilter*)filter;

@end
