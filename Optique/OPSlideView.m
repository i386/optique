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

-(void)copy:(id)sender
{
//    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
//    NSArray *selected = [_controller.collection itemsAtIndexes:[_controller selectedItems]];
//    if (selected.count == 1)
//    {
//        id<XPItem> item = [selected lastObject];
//        [pasteboard writeItem:item];
//    }
//    else if (selected.count > 1)
//    {
//        [pasteboard writeItems:selected];
//    }
}

@end
