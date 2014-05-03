//
//  NSData+WriteImage.h
//  Optique
//
//  Created by James Dumay on 3/05/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (WriteImage)

/**
 Write data as a image with the given UTI
 */
-(BOOL)writeImage:(NSURL *)url withUTI:(CFStringRef)uti;

@end
