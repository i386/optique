//
//  OPDarkroomEditOperation.h
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "OPImage.h"

@protocol OPDarkroomOperation <NSObject>

-(void)performPreview:(CALayer*)layer forItem:(id<XPItem>)item;

-(OPImage*)perform:(OPImage*)image forItem:(id<XPItem>)item;

@end
