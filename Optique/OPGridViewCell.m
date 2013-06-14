//
//  OPGridViewCell.m
//  Optique
//
//  Created by James Dumay on 14/06/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPGridViewCell.h"
#import "NSColor+Optique.h"

@implementation OPGridViewCell

-(id)init
{
    self = [super init];
    if (self)
    {
//        _selectionLayer = [CALayer layer];
//        _selectionLayer.backgroundColor = [[NSColor optiqueSelectedBackgroundColor] CGColor];
//        [self addSublayer:_selectionLayer];
        
        _imageLayer = [OEGridLayer layer];
        _imageLayer.contentsGravity = kCAGravityResize;
        _imageLayer.borderWidth = 0.3;
        _imageLayer.borderColor = [[NSColor blackColor] CGColor];
        [self addSublayer:_imageLayer];
        
        _titleLayer = [CATextLayer layer];
        [_titleLayer setFont:@"HelveticaNeue-Light"];
        [_titleLayer setFontSize:14];
        [_titleLayer setAlignmentMode:kCAAlignmentCenter];
        [_titleLayer setForegroundColor:[[NSColor blackColor] CGColor]];
        [_titleLayer setBackgroundColor:[[NSColor optiqueBackgroundColor] CGColor]];
        [_titleLayer setTruncationMode:kCATruncationMiddle];
        [self addSublayer:_titleLayer];
    }
    return self;
}

-(void)layoutSublayers
{
//    [_selectionLayer setFrame:self.bounds];
    
    CGFloat inset = [[self class] selectionInset];
    CGRect imageRect = CGRectInset(self.bounds, inset, inset);
    [_imageLayer setFrame:imageRect];
    CGPathRef shadowPath = CGPathCreateWithRect([_imageLayer bounds], NULL);
    if (_imageLayer.shadowOpacity) {
        [_imageLayer setShadowPath:shadowPath];
    }
 
    NSRect textRect = NSMakeRect(self.bounds.origin.x,
                                 NSHeight(self.bounds),
                                 NSWidth(self.bounds),
                                 20);
    
    [_titleLayer setFrame:textRect];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _selectionLayer.hidden = YES;
}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//	_selectionLayer.hidden = !selected;
//	[super setSelected:selected animated:animated];
//}

- (void)setImage:(NSImage *)image
{
    if (image) {
        [_imageLayer setContents:image];
//        _imageLayer.shadowColor = kImageLayerShadowColor;
//        _imageLayer.shadowOpacity = kImageLayerShadowOpacity;
//        _imageLayer.shadowRadius = kImageLayerShadowBlurRadius;
//        _imageLayer.shadowOffset = kImageLayerShadowOffset;
//        _imageLayer.opaque = YES;
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

+ (CGFloat)selectionInset
{
    return 6.f;
}

@end
