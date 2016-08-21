//
// Created by BLACKGENE on 8/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerReflectingCircularCombineEffect.h"
#import "STGIFFDisplayLayerCrossFadeMaskEffect.h"
#import "UIImage+STUtil.h"
#import "STGIFFDisplayLayerCrossFadeGradientMaskEffect.h"
#import "NYXImagesKit.h"

@implementation STGIFFDisplayLayerReflectingCircularCombineEffect

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {

    CGFloat diameter = CGSizeMinSide(sourceImages[0].size);

    UIImage * circularClippedImage = [[sourceImages[0] rotateImagePixelsInDegrees:180] clipAsCircle:diameter*.75f scale:sourceImages[0].scale fillColor:[UIColor whiteColor]];

    //TODO: gradient의 경계선 부근에 원근감을 주기 위해서 흰색 gradient띠가 하나 더 필요
    STGIFFDisplayLayerCrossFadeGradientMaskEffect * crossFadeGradientMaskEffect = STGIFFDisplayLayerCrossFadeGradientMaskEffect.new;
    crossFadeGradientMaskEffect.automaticallyMatchUpColors = NO;

//    return [crossFadeGradientMaskEffect processImages:@[sourceImages[0],circularClippedImage]];
    circularClippedImage = [crossFadeGradientMaskEffect processImages:@[[UIImage imageAsColor:[UIColor whiteColor] withSize:sourceImages[0].size],circularClippedImage]];


    return [crossFadeGradientMaskEffect processImages:@[sourceImages.count>1 ? sourceImages[1] : sourceImages[0], circularClippedImage]];


//    STGIFFDisplayLayerCrossFadeMaskEffect * combineEffect = STGIFFDisplayLayerCrossFadeMaskEffect.new;
//    combineEffect.maskImageSource = [STRasterizingImageSourceItem itemWithBundleFileName:@"STGIFFDisplayLayerCrossFadeEffect_patt4.svg"];
//
//    //when process with single source, result should transform
//    if(sourceImages.count==1){
//        combineEffect.transformFadingImage = CGAffineTransformMakeScale(-1,1);
//    }
//
//    UIImage * result = [combineEffect processImages:sourceImages];
//    CGFloat diameter = CGSizeMinSide(result.size);
//
//    //https://github.com/metasmile/DominantColor (import)
//    UIColor * fillColor = nil;
//    LEColorScheme * colorScheme0 = [self st_cachedObject:[sourceImages[0] st_uid] init:^id {
//        return [[STGIFFDisplayLayerEffectSharedUtil colorPicker] colorSchemeFromImage:sourceImages[0]];
//    }];
//    fillColor = colorScheme0.backgroundColor;
//
//    //fill color with second source image
//    if(sourceImages.count>1){
//        LEColorScheme * colorScheme1 = [self st_cachedObject:[sourceImages[1] st_uid] init:^id {
//            return [[STGIFFDisplayLayerEffectSharedUtil colorPicker] colorSchemeFromImage:sourceImages[1]];
//        }];
//        fillColor = [colorScheme1.backgroundColor colorByInterpolatingWith:fillColor factor:.5];
//    }
//
//    fillColor = [fillColor darken:.7f];
//
//    return [result clipAsCircle:diameter*.9f scale:result.scale fillColor:fillColor];
}

@end