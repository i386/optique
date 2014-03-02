//
//  OPPlayerLayer.m
//  Optique
//
//  Created by James Dumay on 29/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPPlayerLayer.h"
#import "OPProgressLayer.h"

@interface OPPlayerLayer()

@property (assign) id observer;
@property (strong) AVPlayerLayer *playerLayer;
@property (strong) OPProgressLayer *progressLayer;
@property (assign) BOOL mouseMoved;

@end

@implementation OPPlayerLayer

-(id)initWithPlayer:(AVPlayer *)player
{
    self = [super init];
    if (self)
    {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        [self addSublayer:_playerLayer];
        
        _progressLayer = [[OPProgressLayer alloc] init];
        [self addSublayer:_progressLayer];
        
        _progressLayer.progressTintColor = [NSColor whiteColor];
    }
    return self;
}

-(void)layoutSublayers
{
    [super layoutSublayers];
    [_playerLayer setFrame:self.frame];
    [_progressLayer setNeedsDisplay];
    [_progressLayer setFrame:NSMakeRect(CGRectGetMidX(self.frame) - (50/2), CGRectGetMidY(self.frame) - (50/2), 50, 50)];
}

-(void)stopPlayback
{
    [_playerLayer.player pause];
    [_playerLayer.player seekToTime:kCMTimeZero];
    [self showStopButton];
}

-(void)togglePlayback
{
    //TODO: find a better way to check for this
    if ([_playerLayer.player rate] == 0.0)
    {
        [_playerLayer.player play];
        [self observePlayback];
        [self performSelector:@selector(hideStopButton) withObject:nil afterDelay:2.0];
    }
    else
    {
        [self stopPlayback];
    }
}

-(void)showStopButton
{
    [_progressLayer setHidden:NO];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideStopButton) object:nil];
    
    if ([_playerLayer.player rate] > 0.0)
    {
        [self performSelector:@selector(hideStopButton) withObject:nil afterDelay:1.0];
    }
}

-(void)hideStopButton
{
    if ([_playerLayer.player rate] != 0.0)
    {
        [_progressLayer setHidden:YES];
    }
}

-(void)observePlayback
{
    if (_observer) return;
    
    __block OPPlayerLayer *strongSelf = self;
    _observer = [_playerLayer.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5f, NSEC_PER_SEC)
                                                          queue:NULL  usingBlock:
                     ^(CMTime time)
                     {
                         [strongSelf syncScrubber];
                     }];
}

- (void)syncScrubber
{
    CMTime playerDuration = [_playerLayer.player.currentItem duration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        [_progressLayer setProgress:0 animated:NO];
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    double time = CMTimeGetSeconds([self.playerLayer.player currentTime]);
    
    if (isfinite(duration) && (duration > 0))
    {
        [_progressLayer setProgress:time / duration];
    }
    
    if (time >= CMTimeGetSeconds([_playerLayer.player.currentItem duration]))
    {
        [_progressLayer setProgress:0 animated:NO];
        [_playerLayer.player seekToTime:kCMTimeZero];
    }
}

@end
