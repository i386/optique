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

@interface OPItemGridViewCell()

@property (assign, getter = isVideo) BOOL video;

@end

@implementation OPItemGridViewCell

-(id)init
{
    self = [super init];
    if (self)
    {
        self.selectionLayer = [OEGridLayer layer];
        self.selectionLayer.borderColor = [[NSColor optiqueSelectionBorderColor] CGColor];
        self.selectionLayer.borderWidth = 5.0f;
        [self addSublayer:self.selectionLayer];
        
        self.imageLayer = [OEGridLayer layer];
        self.imageLayer.contentsGravity = kCAGravityResizeAspectFill;
        self.imageLayer.masksToBounds = YES;
        self.imageLayer.borderWidth = 0.3;
        self.imageLayer.borderColor = [[NSColor blackColor] CGColor];
        self.imageLayer.backgroundColor = [[NSColor lightGrayColor] CGColor];
        [self addSublayer:self.imageLayer];
        
        NSImage *image = [NSImage imageNamed:@"play"];
        self.videoLayer = [OEGridLayer layer];
        self.videoLayer.contents = (id)image.CGImageRef;
        self.videoLayer.bounds = NSMakeRect(0, 0, 36, 36);
        
        [self addSublayer:self.videoLayer];
    }
    return self;
}

-(void)layoutSublayers
{
    NSRect selectionFrame = NSMakeRect(self.bounds.origin.x - 5, //x
                                       self.bounds.origin.y - 5, //y
                                       self.bounds.size.width + 10, //width
                                       self.bounds.size.height + 10); //height
    
    [self.selectionLayer setFrame:selectionFrame];
    
    [self.imageLayer setFrame:self.bounds];
    
    if (self.badgeLayer)
    {
        self.badgeLayer.frame = self.bounds;
    }
    
    [self.videoLayer setHidden:[self.representedObject type] != XPItemTypeVideo];
    
    self.videoLayer.position = NSMakePoint(self.bounds.size.width / 2, self.bounds.size.height / 2);
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

-(void)setBadgeLayer:(CALayer *)badgeLayer
{
    if (self.badgeLayer != nil && self.badgeLayer == nil)
    {
        self.badgeLayer = badgeLayer;
        self.badgeLayer.frame = self.bounds;
        [self addSublayer:self.badgeLayer];
    }
}

@end
