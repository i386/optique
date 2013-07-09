//
//  OPFlickrServiceDelegate.h
//  Optique
//
//  Created by James Dumay on 6/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPFlickrPhotoSet.h"

@class OPFlickrService;

@protocol OPFlickrServiceDelegate <NSObject>

-(void)serviceDidSignIn:(OPFlickrService*)service error:(NSError*)error;

-(void)serviceDidSignOut:(OPFlickrService*)service;

-(void)serviceRequestDidFail:(OPFlickrService*)service error:(NSError*)error;

-(void)service:(OPFlickrService*)service foundSet:(OPFlickrPhotoSet*)photoSet;

@end
