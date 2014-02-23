//
//  OPPhotoGridViewCell.h
//  Optique
//
//  Created by James Dumay on 17/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPGridViewCell.h"

@interface OPItemGridViewCell : OPGridViewCell

@property (nonatomic, retain) id<XPItem> representedObject;

@property (nonatomic, retain) OEGridLayer *imageLayer;
@property (nonatomic, retain) CALayer *badgeLayer;

@end
