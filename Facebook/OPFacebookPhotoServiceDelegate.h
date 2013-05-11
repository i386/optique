//
//  OPFacebookPhotosDelegate.h
//  Optique
//
//  Created by James Dumay on 11/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OPFacebookPhotoService;
@class OPFacebookAlbum;
@class OPFacebookPhoto;

@protocol OPFacebookPhotoServiceDelegate <NSObject>

@optional

-(void)photoService:(OPFacebookPhotoService*)photos album:(OPFacebookAlbum*)album error:(NSError*)error;

-(void)photoService:(OPFacebookPhotoService *)photos photoUploaded:(OPFacebookPhoto *)photo album:(OPFacebookAlbum*)album error:(NSError *)error;

-(void)photoService:(OPFacebookPhotoService *)photos albums:(NSArray*)albums error:(NSError*)error;

@end