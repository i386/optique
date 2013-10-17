//
//  OPPhotoGridViewCell.h
//  Optique
//
//  Created by James Dumay on 17/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OEGridViewCell.h"

@interface OPPhotoGridViewCell : OEGridViewCell

@property (nonatomic, retain) id representedObject;
@property (nonatomic, retain) NSImage *image;

@property (nonatomic, retain) OEGridLayer *imageLayer;
@property (nonatomic, retain) CALayer *selectionLayer;
@property (nonatomic, retain) CALayer *badgeLayer;

@end
