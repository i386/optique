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
#import "OPItemViewController.h"
#import "NSPasteboard+XPItem.h"

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

-(void)copy:(id)sender
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    id<XPItem> item = _viewController.item;
    if (item)
    {
        [pasteboard writeItem:item];
    }
}

@end
