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
#import "NSArray+STUtil.h"
#import "NSData+STGIFUtil.h"
#import "STGIFFDisplayLayerChromakeyEffect.h"


@implementation STGIFFDisplayLayerEffectsManager {

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

- (STCapturedImageSetAnimatableLayerSet *)createLayerSetFrom:(STCapturedImageSet *)imageSet effectClass:(NSString *)classString{
    STCapturedImageSetAnimatableLayerSet * layerSet = [STCapturedImageSetAnimatableLayerSet setWithLayers:@[[STCapturedImageSetAnimatableLayer layerWithImageSet:imageSet]]];
    STMultiSourcingImageProcessor * effect = (STMultiSourcingImageProcessor *)[[NSClassFromString(classString) alloc] init];
    NSAssert(effect, @"Not found effect");
    effect.uuid = [layerSet.uuid st_add:classString];
    layerSet.effect = effect;
    return layerSet;
}

- (void)prepareLayerEffect:(STCapturedImageSetDisplayLayerSet *)layerSet sourceSet:(STCapturedImageSet *)sourceSet{

    if([layerSet.effect isKindOfClass:STGIFFDisplayLayerChromakeyEffect.class]){
        NSData * gifData = [NSData dataWithContentsOfFile:[@"chrogif.gif" bundleFilePath]];

        UIImage * gifImages = UIImageWithAnimatedGIFData(gifData);

        NSArray * imagesToCreateImageSet = nil;
        if(gifImages.images.count > sourceSet.images.count){
            NSRange cuttingRange = NSMakeRange(0,sourceSet.images.count);
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
            preparedImages = sourceSet.images;

        }else{
            //frame adjust
            NSMutableArray<STCapturedImage *> *copiedSourceImages = [sourceSet.images mutableCopy];
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