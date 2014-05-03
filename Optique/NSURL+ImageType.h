//
//  NSURL+ImageType.h
//  Optique
//
//  Created by James Dumay on 3/05/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (ImageType)

/**
 UTI if the URL represents an image
 */
-(CFStringRef)imageUTI;

@end
