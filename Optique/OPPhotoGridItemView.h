//
//  OPAlbumItemView.h
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <CNGridView/CNGridView.h>
#import "OPPhotoGridView.h"

@interface OPPhotoGridItemView : CNGridViewItem<NSDraggingSource> {
    NSDictionary *_attrsDictionary;
}

@property (weak) OPPhotoGridView *gridView;

@end
