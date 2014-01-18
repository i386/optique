//
//  OPImagePreviewService.h
//  Optique
//
//  Created by James Dumay on 3/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPItemPreviewService : NSObject

+(OPItemPreviewService *)defaultService;

-(NSImage*)previewImage:(id<XPItem>)item loaded:(XPImageCompletionBlock)completionBlock;

@end
