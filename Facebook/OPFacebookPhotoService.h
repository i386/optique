//
//  OPFacebook.h
//  Optique
//
//  Created by James Dumay on 11/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import "OPFacebookPhotoServiceDelegate.h"

@interface OPFacebookPhotoService : NSObject

@property (weak) id<OPFacebookPhotoServiceDelegate> delegate;

-(void)createAlbumNamed:(NSString*)name message:(NSString*)message account:(ACAccount*)account;

-(void)uploadPhotos:(NSArray *)photos albums:(OPFacebookAlbum *)album account:(ACAccount *)account;

-(void)allAlbums:(ACAccount*)account;

@end
