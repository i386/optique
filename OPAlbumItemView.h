//
//  OPAlbumItemView.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OPAlbumItem.h"

@interface OPAlbumItemView : NSView {
    IBOutlet OPAlbumItem *delegate;
}

@end
