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

@interface OPCollectionScanner : NSObject<CDEventsDelegate>

@property (readonly, strong) NSOperationQueue *scanningQueue;
@property (readonly, strong) NSOperationQueue *thumbQueue;
@property (readonly, weak) XPCollectionManager *collectionManager;
@property (readonly, weak) OPLocalPlugin *plugin;
@property (readonly, strong) CDEvents *events;
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
