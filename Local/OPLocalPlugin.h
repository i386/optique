//
//  OPLocalPlugin.h
//  Optique
//
//  Created by James Dumay on 17/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Exposure/Exposure.h>
#import "OPCollectionScanner.h"
#import "OPLocalCollection.h"

@interface OPLocalPlugin : NSObject<XPPlugin, XPItemCollectionProvider>

@property (weak, nonatomic) XPCollectionManager *collectionManager;
@property (weak) id<XPItemCollectionProviderDelegate> delegate;
@property (strong, readonly) NSMutableSet *collections;
@property (strong) OPCollectionScanner *scanner;

-(id<XPItemCollection>)collectionWithTitle:(NSString *)title path:(NSURL *)path;
-(id<XPItem>)itemForURL:(NSURL*)url collection:(id<XPItemCollection>)collection;

-(void)didAddAlbums:(NSObject*)albums;
-(void)didRemoveAlbum:(OPLocalCollection*)album;

@end
