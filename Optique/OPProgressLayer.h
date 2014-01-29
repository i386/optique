//
//  OPProgressLayer.h
//  Optique
//
//  Created by James Dumay on 29/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface OPProgressLayer : CALayer

/**
 The progress of the circular view. Only valid for values between `0` and `1`.
 
 The default is `0`.
 */
@property (nonatomic) float progress;

@property (nonatomic) float thickness;

/**
 A tintColor replacement for pre-iOS7 SDK versions. On iOS7 and higher use `tintColor` for setting this.
 
 The default is the parent view's `tintColor` or a black color on versions lower than iOS7.
 */
@property (nonatomic, strong) NSColor *progressTintColor;

/**
 Set the progress of the circular view in an animated manner. Only valid for values between `0` and `1`.
 */
- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
