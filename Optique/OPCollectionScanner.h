//
//  OPAlbumScanner.h
//  Optique
//
//  Created by James Dumay on 29/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Exposure/Exposure.h>
#import <CDEvents/CDEvents.h>
#import <CDEvents/CDEventsDelegate.h>

@class OPLocalPlugin;

@interface OPCollectionScanner : NSObject<CDEventsDelegate> {
    NSOperationQueue *_scanningQueue;
    NSOperationQueue *_thumbQueue;
    CDEvents *_events;
    XPCollectionManager *_collectionManager;
    OPLocalPlugin *_plugin;
}

@property (atomic) BOOL stopScan;

/**
 @param collectionManager for this session
 */
-initWithCollectionManager:(XPCollectionManager*)collectionManager plugin:(OPLocalPlugin*)plugin;

/**
 Scan for new albums
 */
-(void)startScan;

@end
