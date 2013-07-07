//
//  OPPhotoCollectionProvider.h
//  Optique
//
//  Created by James Dumay on 5/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPPlugin.h"
#import "XPPhotoCollectionProviderDelegate.h"

@protocol XPPhotoCollectionProvider <XPPlugin>

@property (weak) id<XPPhotoCollectionProviderDelegate> delegate;

-(NSArray*)photoCollections;

@end
