//
//  OPDarkroomPreviewView.h
//  Optique
//
//  Created by James Dumay on 2/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OPDarkroomPreviewView : NSView

@property (weak, nonatomic) id<XPItem> item;
@property (strong, nonatomic) CALayer *previewLayer;

@end

