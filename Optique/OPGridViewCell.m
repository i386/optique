//
//  OPGridViewCell.m
//  Optique
//
//  Created by James Dumay on 14/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OPGridViewCell.h"
#import "NSColor+Optique.h"
#import "OPCollectionGridView.h"

#define kOPGridViewCellBorderRadius         6
#define OPGridViewCellOSelectionOpacity     0.6

@implementation OPGridViewCell

-(id)init
{
    self = [super init];
    if (self)
    {
        _titleLayer = [CATextLayer layer];
        [_titleLayer setFont:@"HelveticaNeue-Regular"];
        [_titleLayer setFontSize:[NSFont systemFontSize]];
        [_titleLayer setAlignmentMode:kCAAlignmentCenter];
        [_titleLayer setForegroundColor:[[NSColor optiqueItemLabelTextColor] CGColor]];
        [_titleLayer setBackgroundColor:[[NSColor optiqueBackgroundColor] CGColor]];
        [_titleLayer setTruncationMode:kCATruncationMiddle];
        
        [self addSublayer:_titleLayer];
        
        _imageLayer = [OEGridLayer layer];
        _imageLayer.contentsGravity = kCAGravityResizeAspectFill;
        _imageLayer.masksToBounds = YES;
        _imageLayer.cornerRadius = kOPGridViewCellBorderRadius;
        _imageLayer.backgroundColor = [[NSColor optiqueGridItemEmptyColor] CGColor];
        [self addSublayer:_imageLayer];
        
        _selectionLayer = [OEGridLayer layer];
        _selectionLayer.borderColor = [[NSColor optiqueSelectionColor] CGColor];
        _selectionLayer.cornerRadius = kOPGridViewCellBorderRadius;
        _selectionLayer.backgroundColor = [[NSColor optiqueSelectionColor] CGColor];
        _selectionLayer.opacity = OPGridViewCellOSelectionOpacity;
        
        [self addSublayer:_selectionLayer];
        
        [self setEmphaisis:YES];
    }
    return self;
}

-(void)mouseEnteredAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    [self setEmphaisis:!self.emphaisis];
}

-(void)setEmphaisis:(BOOL)emphaisis
{
    if (emphaisis)
    {
        _imageLayer.filters = @[];
    }
    else
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
        [filter setDefaults];
        _imageLayer.filters = @[filter];
    }
}

-(BOOL)emphaisis
{
    return self.filters.count == 0;
}

-(void)layoutSublayers
{
    self.selectionLayer.frame = self.bounds;
    self.imageLayer.frame = self.bounds;
    self.badgeLayer.frame = self.bounds;
 
    NSRect textRect = NSMakeRect(self.bounds.origin.x,
                                 NSHeight(self.bounds) + 5,
                                 NSWidth(self.bounds),
                                 20);
    
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    
    _titleLayer.frame = CGRectIntegral(textRect);
    
    [CATransaction commit];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _selectionLayer.hidden = YES;
    _badgeLayer = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    _selectionLayer.hidden = !selected;
	[super setSelected:selected animated:animated];
}

- (void)setImage:(NSImage *)image
{
    if (image)
    {
        _imageLayer.contents = image;
    }
}

- (NSImage*)image
{
    return _imageLayer.contents;
}

-(void)setTitle:(NSString *)title
{
    if (title)
    {
        _titleLayer.string = title;
    }
}

-(void)setBadgeLayer:(CALayer *)badgeLayer
{
    if (badgeLayer != nil && _badgeLayer == nil)
    {
        _badgeLayer = badgeLayer;
        _badgeLayer.zPosition = 1;
        _badgeLayer.frame = self.imageLayer.bounds;
        
        [self addSublayer:_badgeLayer];
    }
}

-(NSString *)title
{
    return _titleLayer.string;
}

@end
