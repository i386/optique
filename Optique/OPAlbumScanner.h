//
//  OPAlbumScanner.h
//  Optique
//
//  Created by James Dumay on 29/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CDEvents/CDEvents.h>
#import <CDEvents/CDEventsDelegate.h>
#import "OPCameraService.h"

/** scan started **/
extern NSString *const OPAlbumScannerDidStartScanNotification;

/** scan ended **/
extern NSString *const OPAlbumScannerDidFinishScanNotification;

/** albums were found **/
extern NSString *const OPAlbumScannerDidFindAlbumsNotification;

@interface OPAlbumScanner : NSObject<CDEventsDelegate> {
    NSOperationQueue *_scanningQueue;
    NSOperationQueue *_thumbQueue;
    CDEvents *_events;
    XPPhotoManager *_photoManager;
    OPCameraService *_cameraService;
}

@property (atomic) BOOL stopScan;

-initWithPhotoManager:(XPPhotoManager*)photoManager cameraService:(OPCameraService*)cameraService;

-(void)scanAtURL:(NSURL*)url;

@end
