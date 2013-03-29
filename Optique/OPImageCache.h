//
//  OPImageCache.h
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPImageCache : NSObject <NSCacheDelegate> {
    NSURL *_cacheDirectory;
    NSSize _size;
}

+(OPImageCache*)sharedPreviewCache;

-(id)initWithIdentity:(NSString *)identity size:(NSSize)size;

-(NSImage *)loadImageForPath:(NSURL *)path;

-(void)cacheImageForPath:(NSURL *)path;

@end
