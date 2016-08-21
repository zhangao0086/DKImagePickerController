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

    STGIFFDisplayLayerCrossFadeGradientMaskEffect * crossFadeGradientMaskEffect = STGIFFDisplayLayerCrossFadeGradientMaskEffect.new;
    crossFadeGradientMaskEffect.automaticallyMatchUpColors = NO;

    circularClippedImage = [crossFadeGradientMaskEffect processImages:@[[UIImage imageAsColor:[UIColor whiteColor] withSize:sourceImages[0].size],circularClippedImage]];

    crossFadeGradientMaskEffect.locations = @[@.25, @.65];
    return [crossFadeGradientMaskEffect processImages:@[sourceImages.count>1 ? sourceImages[1] : sourceImages[0], circularClippedImage]];
}

@end