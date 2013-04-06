//
//  OPEffectProcessedImageRef.h
//  Optique
//
//  Created by James Dumay on 6/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPEffectProcessedImageRef : NSObject

@property (strong, readonly) NSImage *image;
@property (strong, readonly) NSString *effect;

+newWithImage:(NSImage*)image effect:(NSString*)name;

-initWithImage:(NSImage*)image effect:(NSString*)name;

@end
