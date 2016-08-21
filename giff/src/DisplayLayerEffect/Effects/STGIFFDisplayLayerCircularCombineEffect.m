//
// Created by BLACKGENE on 8/18/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerCircularCombineEffect.h"
#import "STGIFFDisplayLayerCrossFadeMaskEffect.h"
#import "UIImage+STUtil.h"
#import "LEColorPicker.h"
#import "NSObject+STUtil.h"
#import "Colours.h"
#import "UIColor+STColorUtil.h"
#import "STRasterizingImageSourceItem.h"


@implementation STGIFFDisplayLayerCircularCombineEffect {
    LEColorPicker * _colorPicker;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _colorPicker = LEColorPicker.new;
    }

    return self;
}


- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    STGIFFDisplayLayerCrossFadeMaskEffect * combineEffect = STGIFFDisplayLayerCrossFadeMaskEffect.new;
    combineEffect.maskImageSource = [STRasterizingImageSourceItem itemWithBundleFileName:@"STGIFFDisplayLayerCrossFadeEffect_patt4.svg"];

    //when process with single source, result should transform
    if(sourceImages.count==1){
        combineEffect.transformFadingImage = CGAffineTransformMakeScale(-1,1);
    }

    UIImage * result = [combineEffect processImages:sourceImages];
    CGFloat diameter = CGSizeMinSide(result.size);

    //https://github.com/metasmile/DominantColor (import)
    UIColor * fillColor = nil;
    LEColorScheme * colorScheme0 = [self st_cachedObject:[sourceImages[0] st_uid] init:^id {
        return [_colorPicker colorSchemeFromImage:sourceImages[0]];
    }];
    fillColor = colorScheme0.backgroundColor;

    //fill color with second source image
    if(sourceImages.count>1){
        LEColorScheme * colorScheme1 = [self st_cachedObject:[sourceImages[1] st_uid] init:^id {
            return [_colorPicker colorSchemeFromImage:sourceImages[1]];
        }];
        fillColor = [colorScheme1.backgroundColor colorByInterpolatingWith:fillColor factor:.5];
    }

    fillColor = [fillColor darken:.7f];

    return [result clipAsCircle:diameter*.9f scale:result.scale fillColor:fillColor];
}

@end