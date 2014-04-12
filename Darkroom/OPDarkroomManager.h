//
//  OPDarkroomEditManager.h
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPDarkroomOperation.h"

@interface OPDarkroomManager : NSObject

+(BOOL)IsWritableInNativeFormat:(id<XPItem>)item;

@property (readonly) NSUInteger count;

-initWithItem:(id<XPItem>)item previewLayer:(CALayer*)layer;

-(void)addOperation:(id<OPDarkroomOperation>)operation;

-(void)commit;

@end
