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

-(OPImage*)perform:(OPImage*)image layer:(CALayer*)layer;

@end
