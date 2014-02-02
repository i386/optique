//
//  OPGridViewCell.m
//  Optique
//
//  Created by James Dumay on 14/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPGridViewCell.h"
#import "NSColor+Optique.h"
#import "OPCollectionGridView.h"

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
        [_titleLayer setForegroundColor:[[NSColor blackColor] CGColor]];
        [_titleLayer setBackgroundColor:[[NSColor optiqueBackgroundColor] CGColor]];
        [_titleLayer setTruncationMode:kCATruncationMiddle];
        
        [self addSublayer:_titleLayer];
        
        _imageLayer = [OEGridLayer layer];
        _imageLayer.contentsGravity = kCAGravityResizeAspectFill;
        _imageLayer.masksToBounds = YES;
        _imageLayer.borderWidth = 0.3;
        _imageLayer.borderColor = [[NSColor blackColor] CGColor];
        _imageLayer.backgroundColor = [[NSColor lightGrayColor] CGColor];
        [self addSublayer:_imageLayer];
        
        _selectionLayer = [OEGridLayer layer];
        _selectionLayer.borderColor = [[NSColor optiqueSelectionBorderColor] CGColor];
        _selectionLayer.borderWidth = 5.0f;
        [self addSublayer:_selectionLayer];
    }
    return self;
}

-(void)layoutSublayers
{
    NSRect selectionFrame = NSMakeRect(self.bounds.origin.x - 5, //x
                                       self.bounds.origin.y - 5, //y
                                       self.bounds.size.width + 10, //width
                                       self.bounds.size.height + 10); //height
    
    [_selectionLayer setFrame:CGRectIntegral(selectionFrame)];
    
    [_imageLayer setFrame:self.bounds];
 
    NSRect textRect = NSMakeRect(self.bounds.origin.x,
                                 NSHeight(self.bounds) + 5,
                                 NSWidth(self.bounds),
                                 20);
    
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    
    [_titleLayer setFrame:CGRectIntegral(textRect)];
    [CATransaction commit];
    
    if (_badgeLayer)
    {
        _badgeLayer.frame = self.bounds;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _selectionLayer.hidden = YES;
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
        [_imageLayer setContents:image];
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
        [_titleLayer setString:title];
    }
}

-(void)setBadgeLayer:(CALayer *)badgeLayer
{
    if (badgeLayer != nil && _badgeLayer == nil)
    {
        _badgeLayer = badgeLayer;
        _badgeLayer.frame = self.bounds;
        [self addSublayer:_badgeLayer];
    }
}

-(NSString *)title
{
    return _titleLayer.string;
}

@end
