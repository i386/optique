//
//  OPAlbumScanner.h
//  Optique
//
//  Created by James Dumay on 29/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

/** scan started **/
NSString *const OPAlbumScannerDidStartScanNotification;

/** scan ended **/
NSString *const OPAlbumScannerDidFinishScanNotification;

NSString *const OPAlbumScannerDidFindAlbumsNotification;

/** scan found a new album **/
NSString *const OPAlbumScannerDidFindAlbumNotification;

@interface OPAlbumScanner : NSObject {
    NSOperationQueue *_scanningQueue;
    NSOperationQueue *_thumbQueue;
}

-(void)scanAtURL:(NSURL*)url;

@end
