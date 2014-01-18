//
//  NSPasteboard+XPItem.h
//  Optique
//
//  Created by James Dumay on 30/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSPasteboard (XPItem)

-(void)writeItem:(id<XPItem>)item;

-(void)writeItems:(NSArray*)items;

@end
