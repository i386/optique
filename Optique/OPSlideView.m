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
    if ([self.visibleLayer isKindOfClass:[OPPlayerLayer class]])
    {
        OPPlayerLayer *playerLayer = (OPPlayerLayer*)self.visibleLayer;
        [playerLayer stopPlayback];
    }
}

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)magnifyWithEvent:(NSEvent *)event
{
    NSLog(@"%@", [NSString stringWithFormat:@"Magnification value is %f", [event magnification]+1.0]);
    self.visibleLayer.contentsScale = [event magnification] + 1.0;
    [self.visibleLayer needsDisplay];
}

@end
