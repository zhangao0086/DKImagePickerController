//
// Created by BLACKGENE on 2016. 1. 7..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STLivePhotoView.h"


@implementation STLivePhotoView {
    id <PHLivePhotoViewDelegate> _delegateProxy;
}

#pragma mark Override
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setDelegate:(id <PHLivePhotoViewDelegate>)delegate {
    _delegateProxy = delegate;
}

- (void)startPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    [super startPlaybackWithStyle:playbackStyle];
    _playbackStyle = playbackStyle;
}

- (void)stopPlayback {
    [super stopPlayback];

    self.repeats = NO;
    [self _playing:NO];
}

- (void)dealloc {
    _delegateProxy = nil;
}

#pragma mark Impl.
- (void)setup {
    super.delegate = self;
}

- (void)startPlayback {
    [super startPlaybackWithStyle:_playbackStyle];
}

- (void)_playing:(BOOL)playing{
    if(_playing!=playing){
        [self willChangeValueForKey:@keypath(self.playing)];
        _playing = playing;
        [self didChangeValueForKey:@keypath(self.playing)];
    }
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    [self _playing:YES];

    if([_delegateProxy respondsToSelector:@selector(livePhotoView:willBeginPlaybackWithStyle:)]){
        [_delegateProxy livePhotoView:livePhotoView willBeginPlaybackWithStyle:playbackStyle];
    }
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    [self _playing:NO];

    if(self.repeats){
        [self startPlayback];
    }

    if([_delegateProxy respondsToSelector:@selector(livePhotoView:didEndPlaybackWithStyle:)]){
        [_delegateProxy livePhotoView:livePhotoView didEndPlaybackWithStyle:playbackStyle];
    }
}

@end