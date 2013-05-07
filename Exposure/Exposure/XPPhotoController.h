//
//  XPPhotoViewController.h
//  Exposure
//
//  Created by James Dumay on 6/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XPPhotoController <NSObject>

-(NSMenu*)contextMenu;

-(id<XPPhoto>)visiblePhoto;

@end