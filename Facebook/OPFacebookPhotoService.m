//
//  OPFacebook.m
//  Optique
//
//  Created by James Dumay on 11/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFacebookPhotoService.h"
#import "OPFacebookAlbum.h"
#import "OPFacebookPhoto.h"

@implementation OPFacebookPhotoService

-(void)createAlbumNamed:(NSString *)name message:(NSString *)message account:(ACAccount *)account
{
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://graph.facebook.com/me/albums"] parameters:@{@"message": message, @"name": name}];
    
    [request setAccount:account];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([_delegate respondsToSelector:@selector(photoService:album:error:)])
        {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
            NSString *albumId = [json objectForKey:@"id"];
            if (albumId)
            {
                OPFacebookAlbum *album = [[OPFacebookAlbum alloc] initWithName:name albumId:[albumId integerValue]];
                [_delegate photoService:self album:album error:error];
            }
            else
            {
                [_delegate photoService:self album:nil error:error];
            }
        }
    }];
}

-(void)uploadPhotos:(NSArray *)photos albums:(OPFacebookAlbum *)album account:(ACAccount *)account
{
    for (id<XPPhoto> photo in photos)
    {
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%lu/photos", album.albumId]] parameters:nil];
        
        [request setAccount:account];
        
        NSURL * __block photoURL;
        
        NSConditionLock *condition = [photo resolveURL:^(NSURL *suppliedUrl) {
            photoURL = suppliedUrl;
        }];
        
        [condition lock];
        [condition unlockWithCondition:1];
        
        NSData *data = [NSData dataWithContentsOfURL:photoURL];
        
        [request addMultipartData:data withName:photo.title type:@"multipart/form-data" filename:photo.title];
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if ([_delegate respondsToSelector:@selector(photoService:photoUploaded:album:error:)])
            {
                NSError* error;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
                NSString *photoId = [json objectForKey:@"id"];
                if (photoId)
                {
                    OPFacebookPhoto *facebookPhoto = [[OPFacebookPhoto alloc] initWithPhotoId:[photoId intValue] name:photo.title album:album];
                    [_delegate photoService:self photoUploaded:facebookPhoto album:album error:error];
                }
                else
                {
                    [_delegate photoService:self photoUploaded:nil album:album error:error];
                }
            }
        }];
    }
}

-(void)allAlbums:(ACAccount *)account
{
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://graph.facebook.com/me/albums"] parameters:nil];
    
    [request setAccount:account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([_delegate respondsToSelector:@selector(photoService:albums:error:)])
        {
            NSMutableArray *albums = [NSMutableArray array];
            
            NSError* error;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
            NSArray *data = [json objectForKey:@"data"];
            if (data)
            {
                for (NSDictionary *albumData in data)
                {
                    OPFacebookAlbum *album = [[OPFacebookAlbum alloc] initWithDictionary:albumData];
                    [albums addObject:album];
                }
                
                [_delegate photoService:self albums:albums error:nil];
            }
        }
    }];
}

@end
