//
//  OPDarkroomPreviewView.h
//  Optique
//
//  Created by James Dumay on 2/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPDarkroomPreviewLayer.h"

@interface OPDarkroomPreviewView : NSView

@property (weak, nonatomic) id<XPItem> item;
@property (strong, nonatomic) OPDarkroomPreviewLayer *previewLayer;

@end
