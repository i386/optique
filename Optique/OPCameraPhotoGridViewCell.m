//
//  OPCameraPhotoGridViewCell.m
//  Optique
//
//  Created by James Dumay on 21/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPCameraPhotoGridViewCell.h"
#import "NSImage+CGImage.h"

@interface OPCameraPhotoGridViewCell()
@property (strong) OEGridLayer *selectedBadgeLayer;
@end

@implementation OPCameraPhotoGridViewCell

-(id)init
{
    self = [super init];
    if (self)
    {
        self.badgeLayer = [OEGridLayer layer];
        self.badgeLayer.contents = (id)[[NSImage imageNamed:@"check"] CGImageRef];
        self.badgeLayer.contentsGravity = kCAGravityBottomRight;
        self.badgeLayer.hidden = YES;
        
        [self.selectionLayer addSublayer:self.selectedBadgeLayer];
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    self.badgeLayer.hidden = !selected;
    [super setSelected:selected animated:animated];
}

-(void)dealloc
{
    CGImageRelease((CGImageRef)self.badgeLayer.contents);
}

@end
