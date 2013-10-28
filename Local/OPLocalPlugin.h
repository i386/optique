//
//  OPLocalPlugin.h
//  Optique
//
//  Created by James Dumay on 17/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Exposure/Exposure.h>
#import "OPAlbumScanner.h"
#import "OPPhotoAlbum.h"

@interface OPLocalPlugin : NSObject<XPPlugin, XPPhotoCollectionProvider>

@property (weak) XPPhotoManager *photomanager;
@property (weak) id<XPPhotoCollectionProviderDelegate> delegate;
@property (strong, readonly) NSMutableSet *photoCollections;
@property (strong) OPAlbumScanner *albumScanner;

-(id<XPPhotoCollection>)createCollectionWithTitle:(NSString *)title path:(NSURL *)path;

-(void)didAddAlbums:(NSObject*)albums;
-(void)didRemoveAlbum:(OPPhotoAlbum*)album;

@end
