//
//  OPAlbumScanner.h
//  Optique
//
//  Created by James Dumay on 29/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

/** scan started **/
NSString *const OPAlbumScannerDidStartScan;

/** scan ended **/
NSString *const OPAlbumScannerDidFinishScan;

/** scan found a new album **/
NSString *const OPAlbumScannerDidFindAlbumNotification;

@interface OPAlbumScanner : NSObject {
    NSOperationQueue *_scanningQueue;
    NSOperationQueue *_thumbQueue;
}

-(void)scanAtURL:(NSURL*)url;

@end
