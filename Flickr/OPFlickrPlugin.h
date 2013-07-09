//
//  OPFlickr.h
//  Optique
//
//  Created by James Dumay on 5/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPFlickrService.h"
#import "OPFlickrServiceDelegate.h"

@interface OPFlickrPlugin : NSObject<XPPlugin, XPPhotoCollectionProvider, OPFlickrServiceDelegate>

@property (strong) NSMutableArray* photoCollections;
@property (weak) id<XPPhotoCollectionProviderDelegate> delegate;
@property (strong) OPFlickrService *flickrService;

@end
