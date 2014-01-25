//
//  OPPhotoImageView.h
//  Optique
//
//  Created by James Dumay on 20/04/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OPPhotoImageView : NSImageView<NSDraggingSource>

@property (nonatomic, weak) IBOutlet NSMenu *contextMenu;
@property (nonatomic) id<XPItem> representedObject;

@end
