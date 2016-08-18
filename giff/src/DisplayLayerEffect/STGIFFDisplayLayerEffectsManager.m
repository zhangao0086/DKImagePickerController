//
// Created by BLACKGENE on 8/1/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerEffectsManager.h"
#import "STCapturedImageSetAnimatableLayerSet.h"
#import "STCapturedImageSetAnimatableLayer.h"
#import "STGIFFDisplayLayerLeifEffect.h"
#import "STCapturedImageSet.h"
#import "NSString+STUtil.h"
#import "STGIFFDisplayLayerFrameSwappingColorizeBlendEffect.h"
#import "STCapturedImage.h"
#import "STGIFFDisplayLayerEffectItem.h"
#import "NSArray+STUtil.h"
#import "NSData+STGIFUtil.h"
#import "STGIFFDisplayLayerChromakeyEffect.h"
#import "NSObject+STUtil.h"
#import "STGIFFDisplayLayerColorizeEffect.h"
#import "STGIFFDisplayLayerFluorEffect.h"
#import "STGIFFDisplayLayerAfterImagePopStarEffect.h"
#import "STGIFFDisplayLayerPepVentosaEffect.h"
#import "STGIFFDisplayLayerPatternizedCrossFadeEffect.h"
#import "STGIFFDisplayLayerDarkenMaskEffect.h"
#import "STGIFFDisplayLayerCircularCombineEffect.h"

@implementation STGIFFDisplayLayerEffectsManager {
    NSArray <STGIFFDisplayLayerEffectItem *> * _effects;
}

+ (STGIFFDisplayLayerEffectsManager *)sharedManager {
    static STGIFFDisplayLayerEffectsManager *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (NSArray <STGIFFDisplayLayerEffectItem *> *)effects{
    return _effects ?: (_effects = @[
            [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerAfterImagePopStarEffect.class imageName:@"STGIFFDisplayLayerAfterImagePopStarEffect.jpg"]
            , [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerPepVentosaEffect.class imageName:@"STGIFFDisplayLayerPepVentosaEffect.jpg"]
            , [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerDarkenMaskEffect.class imageName:@"STGIFFDisplayLayerDarkenMaskEffect.jpg"]
            , [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerPatternizedCrossFadeEffect.class imageName:@"STGIFFDisplayLayerPatternizedCrossFadeEffect.jpg"
                                     valuesForKeysToApply:@{@"patternImageName" : @"STGIFFDisplayLayerCrossFadeEffect_patt2.svg"}]
            , [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerCircularCombineEffect.class imageName:@"STGIFFDisplayLayerCircularCombineEffect.jpg"]
            , [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerLeifEffect.class imageName:@"STGIFFDisplayLayerLeifEffect.jpg"]
            , [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerFluorEffect.class imageName:@"STGIFFDisplayLayerFluorEffect.jpg"]
    ]);
}

- (STCapturedImageSetAnimatableLayerSet *)createLayerSetFrom:(STCapturedImageSet *)imageSet withEffect:(STGIFFDisplayLayerEffectItem *)effectItem{
    STCapturedImageSetAnimatableLayerSet * layerSet = [STCapturedImageSetAnimatableLayerSet setWithLayers:@[[STCapturedImageSetAnimatableLayer layerWithImageSet:imageSet]]];
    [self acquireLayerEffect:effectItem forLayerSet:layerSet];
    return layerSet;
}

- (STMultiSourcingImageProcessor *)acquireLayerEffect:(STGIFFDisplayLayerEffectItem *)effectItem forLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet{
    NSParameterAssert(effectItem);
    NSParameterAssert(layerSet);

    NSString * effect_uuid = [layerSet.uuid st_add:effectItem.uuid];
    STMultiSourcingImageProcessor * effect = (STMultiSourcingImageProcessor *)[self st_cachedObject:effect_uuid init:^id {
        STMultiSourcingImageProcessor * created_effect = (STMultiSourcingImageProcessor *)[[NSClassFromString(effectItem.className) alloc] init];
        created_effect.uuid = effect_uuid;
        return created_effect;
    }];

    //set effect values
    if(effectItem.valuesForKeysToApply){
        [effect setValuesForMatchedKeysWithDictionary:effectItem.valuesForKeysToApply];
    }
    NSAssert(effect, @"Not found effect");
    layerSet.effect = effect;
    return effect;
}

- (void)prepareLayerEffectFrom:(STCapturedImageSet *)sourceImageSet forLayerSet:(STCapturedImageSetDisplayLayerSet *)layerSet{

    if([layerSet.effect isKindOfClass:STGIFFDisplayLayerChromakeyEffect.class]){
        NSData * gifData = [NSData dataWithContentsOfFile:[@"chrogif.gif" bundleFilePath]];

        UIImage * gifImages = UIImageWithAnimatedGIFData(gifData);

        NSArray * imagesToCreateImageSet = nil;
        if(gifImages.images.count > sourceImageSet.images.count){
            NSRange cuttingRange = NSMakeRange(0,sourceImageSet.images.count);
            imagesToCreateImageSet = [gifImages.images subarrayWithRange:cuttingRange];
        }else{
            //TODO: 이 경우 gif가 imageSet보다 길이 짧은때 정지 화면 아이템을 넣던지 imageSet에서 이미지를 빼던지 보정 처리 필요
        }

        NSArray * capturedImagesFromGifData = [imagesToCreateImageSet mapWithIndex:^id(UIImage * image, NSInteger number) {
            NSURL * url = [[@(number) stringValue] URLForTemp:@"giff_effect_adding_resource_f" extension:@"png"];
            if([UIImagePNGRepresentation(image) writeToURL:url atomically:YES]){
                return [STCapturedImage imageWithImageUrl:url];
            }
            NSAssert(NO, @"write failed");
            return nil;
        }];

        STCapturedImageSetDisplayLayer * effectAppliedLayer = [STCapturedImageSetDisplayLayer layerWithImageSet:[STCapturedImageSet setWithImages: capturedImagesFromGifData]];
        if(effectAppliedLayer){
            layerSet.layers = [layerSet.layers arrayByAddingObjectsFromArray:@[effectAppliedLayer]];
        }
    }
    else if([layerSet.effect isKindOfClass:STGIFFDisplayLayerFrameSwappingColorizeBlendEffect.class]){

        NSArray<STCapturedImage *> * preparedImages = nil;
        STGIFFDisplayLayerFrameSwappingColorizeBlendEffect * _effect = (STGIFFDisplayLayerFrameSwappingColorizeBlendEffect *)layerSet.effect;

        if(_effect.frameIndexOffset==0){
            preparedImages = sourceImageSet.images;

        }else{
            //frame adjust
            NSMutableArray<STCapturedImage *> *copiedSourceImages = [sourceImageSet.images mutableCopy];
            NSUInteger indexAbsStep = (NSUInteger) ABS(_effect.frameIndexOffset);

            if(_effect.frameIndexOffset>0){
                NSArray * tail = [copiedSourceImages pop:indexAbsStep];
                preparedImages = [tail arrayByAddingObjectsFromArray:copiedSourceImages];

            }else if(_effect.frameIndexOffset<0){
                NSArray * head = [copiedSourceImages shift:indexAbsStep];
                preparedImages = [copiedSourceImages arrayByAddingObjectsFromArray:head];
            }
        }

        layerSet.layers = [layerSet.layers arrayByAddingObjectsFromArray:@[
                [STCapturedImageSetDisplayLayer layerWithImageSet:[STCapturedImageSet setWithImages:preparedImages]]
        ]];

    }
}

@end