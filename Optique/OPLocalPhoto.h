//
//  OPLocalPhoto.h
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Exposure/Exposure.h>

@interface OPLocalPhoto : NSObject <XPPhoto>

@property (strong, readonly) NSString *title;
@property (strong, readonly) NSDate *created;
@property (strong, readonly) NSURL *path;
@property (weak, readonly) id<XPPhotoCollection> collection;

-(id)initWithTitle:(NSString *)title path:(NSURL *)path album:(id<XPPhotoCollection>)collection;

@end
