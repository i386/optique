//
//  OPDarkroomEditManager.h
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPDarkroomEditOperation.h"

@interface OPDarkroomEditManager : NSObject

-initWithItem:(id<XPItem>)item previewLayer:(CALayer*)layer;

-(void)addOperation:(id<OPDarkroomEditOperation>)operation;

@end