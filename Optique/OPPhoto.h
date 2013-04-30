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

/**
 The photo title
 **/
-(NSString*)title;

/**
 The collection (such as the album or camera) that the photo belongs to
 **/
-(id<OPPhotoCollection>) collection;

/**
 Loads the image and returns it via the completion block
 **/
-(void)imageWithCompletionBlock:(OPImageCompletionBlock)completionBlock;

/**
 Loads and scales the image and returns it via the completion block
 May return the full size image if scaling is not available.
 **/
-(void)scaleImageToFitSize:(NSSize)size withCompletionBlock:(OPImageCompletionBlock)completionBlock;

/** 
 Loads the data representing this photo and returns it via the completion block 
 **/
-(void)resolveURL:(OPURLSupplier)block;

@end
