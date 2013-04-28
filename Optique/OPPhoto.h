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

-(NSImage*)image;

-(NSImage*)scaleImageToFitSize:(NSSize)size;

@end
