//
//  OPToolbarItemProvider.h
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPItem.h"

@protocol XPToolbarItemProvider <XPItem>

-(NSToolbarItem*)toolbarItemForIdentifier:(NSString*)identifier;

-(void)addToolbarItemsForToolbar:(NSToolbar*)toolbar;

@end
