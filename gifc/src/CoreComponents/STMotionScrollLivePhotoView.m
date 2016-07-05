//
// Created by BLACKGENE on 2016. 1. 7..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Photos/Photos.h>
#import "STMotionScrollLivePhotoView.h"
#import "STLivePhotoView.h"
#import "UIView+STUtil.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"
@interface STMotionScrollView()
- (CGSize)assetsSizeToFitScreen;
@end

@interface STMotionScrollLivePhotoView()
@end

@implementation STMotionScrollLivePhotoView

- (void)disposeContent {
    self.assetAsLivePhoto = nil;

    [super disposeContent];
}

- (void)setAssetAsLivePhoto:(PHAsset *)assetAsLivePhoto {
    BOOL replaceOrUpdate = ![assetAsLivePhoto.localIdentifier isEqualToString:self.asset.localIdentifier];

    self.asset = assetAsLivePhoto;

    //dispose (set to nil)
    if(!self.asset){
        if(self.contentLivePhotoView){
            [self.contentLivePhotoView stopPlayback];
            self.contentLivePhotoView.livePhoto = nil;
            _contentLivePhotoView = nil;
        }
        self.contentView = _contentLivePhotoView;
        return;
    }

    //new or update
    if(replaceOrUpdate){
        Weaks
        CGSize size = [self assetsSizeToFitScreen];

        PHLivePhotoRequestOptions *livePhotoOptions = [[PHLivePhotoRequestOptions alloc] init];
        livePhotoOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        livePhotoOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            // this block is in NOT main thread.
            dispatch_async(dispatch_get_main_queue(), ^{

            });
        };

        [[PHImageManager defaultManager] requestLivePhotoForAsset:self.asset targetSize:size contentMode:PHImageContentModeDefault options:livePhotoOptions resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
            if (!livePhoto) {
                return;
            }
            Strongs

            if([info[PHImageCancelledKey] boolValue] || [info[PHImageErrorKey] boolValue]){
                Sself.image = nil;
                Sself.assetAsLivePhoto = nil;
            }

            if (![info[PHImageResultIsDegradedKey] boolValue]) {
                Sself.image = nil;

                if(!Sself.contentLivePhotoView){
                    [Sself willChangeValueForKey:@keypath(Sself.contentLivePhotoView)];
                    Sself->_contentLivePhotoView = [[STLivePhotoView alloc] initWithSize:size];
                    [Sself didChangeValueForKey:@keypath(Sself.contentLivePhotoView)];

                    Sself.contentLivePhotoView.userInteractionEnabled = YES;
                    Sself.contentLivePhotoView.contentMode = UIViewContentModeScaleAspectFit;

                }else{
                    [Sself.contentLivePhotoView stopPlayback];
                }

                Sself.contentView = Sself.contentLivePhotoView;
                Sself.contentLivePhotoView.livePhoto = livePhoto;

                [Sself.contentLivePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
            }

        }];
        return;
    }

    //exists
    //TODO: pause and replay?
}

- (PHAsset *)assetAsLivePhoto {
    return self.asset;
}


@end
#pragma clang diagnostic pop