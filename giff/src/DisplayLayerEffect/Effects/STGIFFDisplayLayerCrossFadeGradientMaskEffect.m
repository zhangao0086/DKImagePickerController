//
// Created by BLACKGENE on 8/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerCrossFadeGradientMaskEffect.h"
#import "CALayer+STUtil.h"
#import "STGIFFDisplayLayerCrossFadeMaskEffect.h"
#import "NSObject+STUtil.h"
#import "NSString+STUtil.h"
#import "R.h"
#import "CCARadialGradientLayer.h"
#import "LEColorPicker.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageMonochromeFilter.h"
#import "GPUImageMonochromeFilter+STGPUImageFilter.h"


@implementation STGIFFDisplayLayerCrossFadeGradientMaskEffect {
    LEColorPicker * _colorPicker;
}

- (instancetype)init {
    self = [super init];
    if (self) {

    }

    return self;
}


- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    UIImage * sourceImage = sourceImages[0];

    CGSize sourceImageSize = sourceImage.size;
    CrossFadeGradientMaskEffectStyle style = self.style;
    STGIFFDisplayLayerCrossFadeMaskEffect * crossFadeEffect = STGIFFDisplayLayerCrossFadeMaskEffect.new;
    NSString * cacheKey = [@"STGIFFDisplayLayerCrossFadeGradientMaskEffect_gradient_" st_add:[[@(style) stringValue] st_add:NSStringFromCGSize(sourceImageSize)]];
    crossFadeEffect.maskImage = [self st_cachedImage:cacheKey init:^UIImage * {

        switch(style){
            case CrossFadeGradientMaskEffectStyleLinearVertical:{
                CAGradientLayer * gradientLayer = [[CAGradientLayer alloc] init];
                gradientLayer.startPoint = CGPointMake(0.5,1.0);
                gradientLayer.endPoint = CGPointMake(0.5,0.0);
                gradientLayer.frame = (CGRect){CGPointZero, sourceImageSize};
                gradientLayer.colors = @[
                        (id)[[UIColor whiteColor] CGColor]
                        , (id)[[UIColor blackColor] CGColor]
                ];
                gradientLayer.locations = @[@.4, @.8];
                return [gradientLayer UIImage:YES];
            }

            case CrossFadeGradientMaskEffectStyleLinearHorizontal:{
                CAGradientLayer * gradientLayer = [[CAGradientLayer alloc] init];
                gradientLayer.startPoint = CGPointMake(0.0,.5);
                gradientLayer.endPoint = CGPointMake(1.0,.5);
                gradientLayer.frame = (CGRect){CGPointZero, sourceImageSize};
                gradientLayer.colors = @[
                        (id)[[UIColor whiteColor] CGColor]
                        , (id)[[UIColor blackColor] CGColor]
                ];
                gradientLayer.locations = @[@.4, @.8];
                return [gradientLayer UIImage:YES];
            }

            case CrossFadeGradientMaskEffectStyleRadial:{
                CCARadialGradientLayer * radialGradientLayer = [CCARadialGradientLayer layer];
                radialGradientLayer.frame = (CGRect){CGPointZero, sourceImageSize};
                CGFloat minSideSize = CGSizeMinSide(sourceImageSize);
                radialGradientLayer.gradientOrigin = CGPointMake(minSideSize/2, minSideSize/2);
                radialGradientLayer.gradientRadius = minSideSize/2;
                radialGradientLayer.colors = @[
                        (id)[[UIColor whiteColor] CGColor]
                        , (id)[[UIColor blackColor] CGColor]
                ];
                radialGradientLayer.locations = @[@.6, @1];
                return [radialGradientLayer UIImage:YES];
            }
        }

        return nil;
    }];

    NSArray * composersForCrossFadeEffect = [crossFadeEffect composersToProcess:sourceImages];

    if(sourceImages.count>1){
        if(!_colorPicker){
            _colorPicker = [[LEColorPicker alloc] init];
        }
        LEColorScheme * colorScheme1 = [self st_cachedObject:[sourceImages[1] st_uid] init:^id {
            return [_colorPicker colorSchemeFromImage:sourceImages[1]];
        }];

        STGPUImageOutputComposeItem * composeItem = crossFadeEffect.composerItemsOfSourceImages[0];
        composeItem.filters = [composeItem.filters arrayByAddingObject:[GPUImageMonochromeFilter filterWithColor:colorScheme1.backgroundColor]];
    }

    return [crossFadeEffect processComposers:composersForCrossFadeEffect];
}


@end