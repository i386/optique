//
//  OPSlideView.h
//  Optique
//
//  Created by James Dumay on 29/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <WHSlider/WHSlideView.h>

@interface OPSlideView : WHSlideView

@property (strong) NSMenu *contextMenu;

@property (strong, nonatomic) CALayer *visibleLayer;
@property (strong) CALayer *leftLayer;
@property (strong) CALayer *rightLayer;

-(void)visibleLayerMustStopPlaying;

@end
