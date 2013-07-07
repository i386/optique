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

@interface OPFlickrService : NSObject

@property (weak) id<OPFlickrServiceDelegate> delegate;
@property (strong, readonly) GTMOAuthAuthentication *authentication;
@property (strong, readonly) GTMOAuthWindowController *controller;

-(void)signin:(NSWindow*)window;

-(void)signout;

-(void)loadPhotoSets;

@end
