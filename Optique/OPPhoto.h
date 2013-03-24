//
//  OPPhoto.h
//  Optique
//
//  Created by James Dumay on 21/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPPhoto : NSObject

@property (strong, readonly) NSString *name;
@property (strong, readonly) NSURL *path;

-(NSImage*)image;

-initWithName:(NSString*)name path:(NSURL*)path;

@end
