//
//  OPPhotoAlbum.h
//  Optique
//
//  Created by James Dumay on 20/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Exposure/Exposure.h>

@class XPCollectionManager;

@interface OPLocalCollection : NSObject <XPItemCollection>

@property (strong, readonly) NSString *title;
@property (strong) NSDate *created;
@property (strong, readonly) NSURL *path;
@property (strong, readonly) XPCollectionManager *collectionManager;

-(id)initWithTitle:(NSString *)title path:(NSURL *)path collectionManager:(XPCollectionManager*)collectionManager;

@end
