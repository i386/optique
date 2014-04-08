//
//  OPCameraThumnailCache.h
//  Optique
//
//  Created by James Dumay on 8/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPCamera.h"

@interface OPCameraThumnailCache : NSObject

-(void)storeThumbnail:(CGImageRef)imageRef forCamera:(OPCamera*)camera;

-(void)flushThumbnailsForCamera:(OPCamera*)camera;

@end
