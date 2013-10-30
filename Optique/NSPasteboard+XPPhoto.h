//
//  NSPasteboard+XPPhoto.h
//  Optique
//
//  Created by James Dumay on 30/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSPasteboard (XPPhoto)

-(void)writePhoto:(id<XPPhoto>)photo;

-(void)writePhotos:(NSArray*)photos;

@end
