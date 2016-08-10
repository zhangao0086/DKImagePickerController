//
// Created by BLACKGENE on 8/10/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "EBRootViewController.h"
#import "STCapturedImageSet.h"
#import "STGIFFAnimatableLayerPresentingView.h"
#import "STCapturedImageSetDisplayLayerSet.h"
#import "STGIFFDisplayLayerEffectsManager.h"
#import "STCapturedImageSetAnimatableLayerSet.h"
#import "STCapturedImageSetAnimatableLayer.h"
#import "UIView+STUtil.h"
#import "STGIFFDisplayLayerEffectItem.h"
#import "NSString+STUtil.h"
#import "STGIFFDisplayLayerColorizeEffect.h"
#import "BlocksKit.h"

@implementation EBRootViewController {

}

- (void)loadView; {
    [super loadView];

    NSMutableArray<STCapturedImageSet *> * images = [NSMutableArray arrayWithCapacity:2];
    [images addObject:[STCapturedImageSet setWithImageURLs:@[[@"effect_thumb.png" bundleFileURL]]]];

    STGIFFAnimatableLayerPresentingView * _layerSetPresentationView = [[STGIFFAnimatableLayerPresentingView alloc] initWithSizeWidth:self.view.width];
    [self.view addSubview:_layerSetPresentationView];

    STGIFFDisplayLayerEffectItem * currentSelectedEffect = [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerColorizeEffect.class titleImageName:nil];

    STCapturedImageSetAnimatableLayerSet * layerSet = [[STGIFFDisplayLayerEffectsManager sharedManager] createLayerSetFrom:images[0] withEffect:currentSelectedEffect.className];
    [[STGIFFDisplayLayerEffectsManager sharedManager] prepareLayerEffectFrom:images[0] forLayerSet:layerSet];

    if(images.count==2){
        layerSet.layers = [layerSet.layers arrayByAddingObject:[STCapturedImageSetAnimatableLayer layerWithImageSet:images[1]]];
        [[STGIFFDisplayLayerEffectsManager sharedManager] prepareLayerEffectFrom:images[1] forLayerSet:layerSet];
    }
    [_layerSetPresentationView appendLayerSet:layerSet];


    //play animation
    if(_layerSetPresentationView.currentLayerSet.frameCount>1){
        [NSTimer bk_scheduledTimerWithTimeInterval:.1 block:^(NSTimer *timer) {
            if(_layerSetPresentationView.currentFrameIndex>=_layerSetPresentationView.currentLayerSet.frameCount-1){
                _layerSetPresentationView.currentFrameIndex=0;
            }else{
                _layerSetPresentationView.currentFrameIndex++;
            }
        } repeats:YES];
    }
}

@end