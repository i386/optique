//
//  NSObject+GraphicsContext.h
//  Optique
//
//  Created by James Dumay on 18/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSGraphicsContext (GraphicsContext)

+(void)withinGraphicsContext:(void (^)(void))block;

@end
