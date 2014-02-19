//
//  OPCollectionWatcher.h
//  Optique
//
//  Created by James Dumay on 16/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Exposure/Exposure.h>

@class OPLocalPlugin;

@interface OPCollectionWatcher : NSObject

/**
 @param collectionManager for this session
 */
-initWithCollectionManager:(XPCollectionManager*)collectionManager plugin:(OPLocalPlugin*)plugin;

/**
 Watch for new collections
 */
-(void)startWatching;

/**
 Stop watching for new collections
 */
-(void)stopWatching;

/**
 Manually scan for new collections
 */
-(void)scanForNewCollections;

@end
