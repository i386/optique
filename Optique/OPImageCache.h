//
//  OPImageCache.h
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kOPImageCacheThumbSize NSMakeSize(310, 225)

@interface OPImageCache : NSObject

+(OPImageCache*)sharedPreviewCache;

-(id)initWithIdentity:(NSString *)identity size:(NSSize)size;

-(NSImage *)loadImageForPath:(NSURL *)path;

-(NSImage*)cacheImageForPath:(NSURL *)path;

-(BOOL)isCachedImageAtPath:(NSURL *)path;

-(void)invalidateImageForPath:(NSURL *)path;

-(void)clearCache;

@end
