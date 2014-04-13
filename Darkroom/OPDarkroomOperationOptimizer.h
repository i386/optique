//
//  OPDarkroomOperationOptimizer.h
//  Optique
//
//  Created by James Dumay on 13/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OPDarkroomOperationOptimizer <NSObject>

-(NSArray*)optimize:(NSArray*)operations;

@end
