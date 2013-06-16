//
//  OPGridViewCell.m
//  Optique
//
//  Created by James Dumay on 14/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPGridViewCell.h"
#import "NSColor+Optique.h"
#import "OPGridView.h"

@implementation OPGridViewCell

-(id)init
{
    self = [super init];
    if (self)
    {
        _selectionLayer = [OEGridLayer layer];
        _selectionLayer.backgroundColor = [[NSColor optiqueSelectedBackgroundColor] CGColor];
        [self addSublayer:_selectionLayer];
        
        _titleLayer = [CATextLayer layer];
        [_titleLayer setFont:@"HelveticaNeue-Light"];
        [_titleLayer setFontSize:14];
        [_titleLayer setAlignmentMode:kCAAlignmentCenter];
        [_titleLayer setForegroundColor:[[NSColor blackColor] CGColor]];
        [_titleLayer setBackgroundColor:[[NSColor optiqueBackgroundColor] CGColor]];
        [_titleLayer setTruncationMode:kCATruncationMiddle];
        [self addSublayer:_titleLayer];
        
        _imageLayer = [OEGridLayer layer];
        _imageLayer.contentsGravity = kCAGravityResize;
        _imageLayer.borderWidth = 0.3;
        _imageLayer.borderColor = [[NSColor blackColor] CGColor];
        [self addSublayer:_imageLayer];
    }
    return self;
}

-(void)layoutSublayers
{
    NSRect selectionFrame = NSMakeRect(kGridViewColumnSpacing * -1, //x
                                       -10, //y
                                       self.bounds.size.width + (kGridViewRowSpacing - 3), //width
                                       self.bounds.size.height + kGridViewColumnSpacing + 20); //height
    
    [_selectionLayer setFrame:selectionFrame];
    
    [_imageLayer setFrame:self.bounds];
    CGPathRef shadowPath = CGPathCreateWithRect([_imageLayer bounds], NULL);
    if (_imageLayer.shadowOpacity)
    {
        [_imageLayer setShadowPath:shadowPath];
    }
 
    NSRect textRect = NSMakeRect(self.bounds.origin.x,
                                 NSHeight(self.bounds) + 5,
                                 NSWidth(self.bounds),
                                 20);
    
    [_titleLayer setFrame:textRect];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _selectionLayer.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [CATransaction begin];
    
	CGColorRef titleBackgroundColor = selected ? [[NSColor optiqueSelectedBackgroundColor] CGColor] : [[NSColor optiqueBackgroundColor] CGColor];
    [_titleLayer setBackgroundColor:titleBackgroundColor];
    
    _selectionLayer.hidden = !selected;
	[super setSelected:selected animated:animated];
    
    [CATransaction commit];
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

-(NSString *)title
{
    return _titleLayer.string;
}

@end
