//
//  NSView+OptiqueBackground.h
//  Optique
//
//  Created by James Dumay on 30/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (OptiqueBackground)

-(void)drawBackground;

-(void)drawTransparentBackground;

-(void)drawDarkBackground;

-(void)drawEffectsViewBackground;

-(void)drawEffectsViewBackgroundSelected;

@end
