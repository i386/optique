//
//  XPPlugin.h
//  Exposure
//
//  Created by James Dumay on 5/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XPCollectionViewController.h"
#import "XPPhotoCollectionViewController.h"
#import "XPPhotoViewController.h"

@protocol XPPlugin <NSObject>

@optional

/**
 Called whenever the collection view is loaded
 **/
-(void)photoManager:(XPPhotoManager*)photoManager collectionViewController:(id<XPCollectionViewController>)controller;

/**
 Called whenever the photo collection view is called
 **/
-(void)photoManager:(XPPhotoManager*)photoManager photoCollectionViewController:(id<XPPhotoCollectionViewController>)controller;

/**
 Called whenever the photo view is loaded
 **/
-(void)photoManager:(XPPhotoManager*)photoManager photoViewController:(id<XPPhotoViewController>)controller;

@end
