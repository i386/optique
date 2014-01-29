//
//  OPPlayerLayer.h
//  Optique
//
//  Created by James Dumay on 29/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface OPPlayerLayer : CALayer

-initWithPlayer:(AVPlayer*)player;

-(void)togglePlayback;

@end
