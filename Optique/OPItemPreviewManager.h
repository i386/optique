//
//  OPItemPreviewManager.h
//  Optique
//
//  Created by James Dumay on 19/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPItemPreviewManager : NSObject

+(OPItemPreviewManager *)defaultManager;

-(void)previewItem:(id<XPItem>)item size:(NSSize)size loaded:(XPImageCompletionBlock)completionBlock;

-(void)clearCache;

@end
