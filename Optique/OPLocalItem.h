//
//  OPLocalPhoto.h
//  Optique
//
//  Created by James Dumay on 28/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Exposure/Exposure.h>

@interface OPLocalItem : NSObject <XPItem, NSPasteboardWriting>

@property (strong, readonly) NSString *title;
@property (strong, readonly) NSDate *_created;
@property (strong, readonly) NSURL *path;
@property (weak, readonly) id<XPItemCollection> collection;
@property (assign) XPItemType type;

-(id)initWithTitle:(NSString *)title path:(NSURL *)path album:(id<XPItemCollection>)collection type:(XPItemType)type;

@end
