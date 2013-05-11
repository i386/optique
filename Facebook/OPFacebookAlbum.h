//
//  OPFacebookAlbum.h
//  Optique
//
//  Created by James Dumay on 11/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPFacebookAlbum : NSObject

@property (readonly) NSUInteger albumId;
@property (readonly, assign) NSString *name;
@property (readonly, assign) NSString *description;
@property (readonly, assign) NSURL *link;
@property (readonly, assign) NSString *privacy;
@property (readonly, assign) NSString *type;
@property (readonly, assign) BOOL canUpload;

-(id)initWithName:(NSString*)name albumId:(NSUInteger)albumId;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
