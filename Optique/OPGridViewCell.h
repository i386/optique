//
//  OPGridViewCell.h
//  Optique
//
//  Created by James Dumay on 14/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OEGridViewCell.h"

@interface OPGridViewCell : OEGridViewCell

@property (nonatomic, retain) id representedObject;
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSString *title;

@property (nonatomic, retain) OEGridLayer *imageLayer;
@property (nonatomic, retain) CATextLayer *titleLayer;
@property (nonatomic, retain) CALayer *selectionLayer;
@property (nonatomic, retain) CALayer *badgeLayer;

@property (nonatomic, assign) BOOL emphaisis;

@end
