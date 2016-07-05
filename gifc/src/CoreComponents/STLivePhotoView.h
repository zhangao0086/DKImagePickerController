//
// Created by BLACKGENE on 2016. 1. 7..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PhotosUI/PhotosUI.h>

@interface STLivePhotoView : PHLivePhotoView <PHLivePhotoViewDelegate>
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, readonly) PHLivePhotoViewPlaybackStyle playbackStyle;
@property (nonatomic, assign) BOOL repeats;

- (void)startPlayback;
@end