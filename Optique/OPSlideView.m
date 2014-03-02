//
//  OPSlideView.m
//  Optique
//
//  Created by James Dumay on 29/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPSlideView.h"
#import "NSWindow+FullScreen.h"
#import "NSView+OptiqueBackground.h"
#import "OPPlayerLayer.h"

@implementation OPSlideView

-(NSMenu *)menu
{
    return _contextMenu;
}

-(void)visibleLayerMustStopPlaying
{
    if ([_visibleLayer isKindOfClass:[OPPlayerLayer class]])
    {
        OPPlayerLayer *playerLayer = (OPPlayerLayer*)_visibleLayer;
        [playerLayer stopPlayback];
    }
}

@end
