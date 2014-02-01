//
//  OPDarkroomEditOperation.h
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol OPDarkroomEditOperation <NSObject>

-(void)performPreviewOperation:(CALayer*)layer;

-(void)performOperation:(CGImageRef)image;

@end
