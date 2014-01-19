//
//  OPPlayerView.h
//  Optique
//
//  Created by James Dumay on 18/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <AVKit/AVKit.h>

@interface OPPlayerView : AVPlayerView<NSDraggingSource>

@property (nonatomic, weak) IBOutlet NSMenu *contextMenu;
@property (nonatomic) id<XPItem> representedObject;

@end

