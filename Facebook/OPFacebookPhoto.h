//
//  OPFacebookPhoto.h
//  Optique
//
//  Created by James Dumay on 11/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPFacebookAlbum.h"

@interface OPFacebookPhoto : NSObject

@property (readonly) NSUInteger photoId;
@property (readonly, assign) NSString *name;
@property (readonly, strong) OPFacebookAlbum *album;

-initWithPhotoId:(NSUInteger)photoId name:(NSString*)photoName album:(OPFacebookAlbum*)album;

@end
