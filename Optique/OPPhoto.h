//
//  OPPhoto.h
//  Optique
//
//  Created by James Dumay on 21/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPPhoto : NSObject

@property (strong, readonly) NSString *title;
@property (strong, readonly) NSURL *path;

-(NSImage*)image;

-initWithTitle:(NSString*)title path:(NSURL*)path;

@end
