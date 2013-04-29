//
//  OPPhoto.h
//  Optique
//
//  Created by James Dumay on 21/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>

@protocol OPPhotoCollection;

@protocol OPPhoto

-(NSString*)title;

-(id<OPPhotoCollection>) collection;

/**
 Loads the image and returns it via the completion block
 **/
-(void)imageWithCompletionBlock:(void (^)(NSImage *image))completionBlock;

/**
 Loads and scales the image and returns it via the completion block
 May return the full size image if scaling is not available.
 **/
-(void)scaleImageToFitSize:(NSSize)size withCompletionBlock:(void (^)(NSImage *image))completionBlock;

@end
