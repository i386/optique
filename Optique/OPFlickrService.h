//
//  OPFlickrService.h
//  Optique
//
//  Created by James Dumay on 6/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <gtm-oauth/GTMOAuthAuthentication.h>
#import <gtm-oauth/GTMOAuthWindowController.h>
#import "OPFlickrServiceDelegate.h"
#import "OPPhotoAlbum.h"
#import <Exposure/Exposure.h>

@interface OPFlickrService : NSObject

@property (weak) id<OPFlickrServiceDelegate> delegate;
@property (strong, readonly) GTMOAuthAuthentication *authentication;
@property (strong, readonly) GTMOAuthWindowController *controller;
@property (strong, readonly) XPPhotoManager *photoManager;

-initWithPhotoManager:(XPPhotoManager*)photoManager;

-(void)signin:(NSWindow*)window;

-(void)signout;

-(void)loadPhotoSets;

-(void)syncPhotoSetToDisk:(OPFlickrPhotoSet*)photoSet;

-(void)uploadPhotoAlbum:(OPPhotoAlbum*)photoAlbum;

@end
