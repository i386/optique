//
//  OPAsyncOperation.h
//  Optique
//
//  Created by James Dumay on 1/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPFuture : NSObject

-(void)signal:(id)obj;

-(id)wait;

@end
