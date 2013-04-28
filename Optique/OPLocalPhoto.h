//
//  OPLocalPhoto.h
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OPPhoto.h"
#import "OPPhotoCollection.h"

@interface OPLocalPhoto : NSObject <OPPhoto>

@property (strong, readonly) NSString *title;
@property (strong, readonly) NSURL *path;

-(id)initWithTitle:(NSString *)title path:(NSURL *)path album:(id<OPPhotoCollection>)collection;

@end
