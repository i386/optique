//
//  OPAlbumScanner.h
//  Optique
//
//  Created by James Dumay on 29/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CDEvents/CDEvents.h>
#import "OPPhotoManager.h"

/** scan started **/
NSString *const OPAlbumScannerDidStartScanNotification;

/** scan ended **/
NSString *const OPAlbumScannerDidFinishScanNotification;

NSString *const OPAlbumScannerDidFindAlbumsNotification;

/** scan found a new album **/
NSString *const OPAlbumScannerDidFindAlbumNotification;

@interface OPAlbumScanner : NSObject <CDEventsDelegate> {
    NSOperationQueue *_scanningQueue;
    NSOperationQueue *_thumbQueue;
    CDEvents *_events;
    OPPhotoManager *_photoManager;
    BOOL _scanStarted;
}

@property (atomic) BOOL stopScan;

-initWithPhotoManager:(OPPhotoManager*)photoManager;

-(void)scanAtURL:(NSURL*)url;

@end
