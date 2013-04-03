//
//  OPImagePreviewService.h
//  Optique
//
//  Created by James Dumay on 3/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPImagePreviewService : NSObject {
    NSOperationQueue *_queue;
}

+(OPImagePreviewService *)defaultService;

-(NSImage*)previewImageAtURL:(NSURL*)url loaded:(void (^)(NSImage *image))loadBlock;

@end
