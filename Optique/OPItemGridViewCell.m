//
//  OPPhotoGridViewCell.m
//  Optique
//
//  Created by James Dumay on 17/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPItemGridViewCell.h"
#import "NSColor+Optique.h"
#import "OPItemGridView.h"
#import "NSImage+CGImage.h"
#import "OPProgressLayer.h"

@interface OPItemGridViewCell()

@property (assign, getter = isVideo) BOOL video;
@property (nonatomic, retain) OPProgressLayer *progressLayer;

@end

@implementation OPItemGridViewCell

-(id)init
{
    self = [super init];
    if (self)
    {
        _progressLayer = [[OPProgressLayer alloc] init];
        [self addSublayer:_progressLayer];
        _progressLayer.progress = 0;
    }
    return self;
}

-(void)layoutSublayers
{
    [super layoutSublayers];
    
    [_progressLayer setHidden:[self.representedObject type] != XPItemTypeVideo];
    [_progressLayer setFrame:NSMakeRect(CGRectGetMidX(self.imageLayer.frame) - (50/2), CGRectGetMidY(self.imageLayer.frame) - (50/2), 50, 50)];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.selectionLayer.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    self.selectionLayer.hidden = !selected;
	[super setSelected:selected animated:animated];
}

- (void)setImage:(NSImage *)image
{
    if (image)
    {
        [self.imageLayer setContents:image];
    }
}

- (NSImage*)image
{
    return self.imageLayer.contents;
}

@end
