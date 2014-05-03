//
//  OPSlideView.h
//  Optique
//
//  Created by James Dumay on 29/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <WHSlider/WHSlideView.h>

@class OPItemViewController;

@interface OPSlideView : WHSlideView

@property (strong) NSMenu *contextMenu;
@property (weak) IBOutlet OPItemViewController *viewController;

-(void)visibleLayerMustStopPlaying;

@end
