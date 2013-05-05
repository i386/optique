//
//  OPImagePreviewService.h
//  Optique
//
//  Created by James Dumay on 3/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPImagePreviewService : NSObject

+(OPImagePreviewService *)defaultService;

-(NSImage*)previewImageWithPhoto:(id<XPPhoto>)photo loaded:(XPImageCompletionBlock)completionBlock;

@end
