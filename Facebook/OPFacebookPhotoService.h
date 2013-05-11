//
//  OPFacebook.h
//  Optique
//
//  Created by James Dumay on 11/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import "OPFacebookPhotosDelegate.h"

@interface OPFacebookPhotoService : NSObject

@property (weak) id<OPFacebookPhotoService> delegate;

-(void)createAlbumNamed:(NSString*)name message:(NSString*)message account:(ACAccount*)account;

-(void)uploadPhotosToAlbumNamed:(NSString*)name photos:(NSArray*)photos account:(ACAccount*)account;

-(void)allAlbums:(ACAccount*)account;

@end
