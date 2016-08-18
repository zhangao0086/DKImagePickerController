//
// Created by BLACKGENE on 8/18/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerCircularCombineEffect.h"
#import "STGIFFDisplayLayerPatternizedCrossFadeEffect.h"
#import "UIImage+STUtil.h"
#import "UIColor+BFPaperColors.h"


@implementation STGIFFDisplayLayerCircularCombineEffect {

}


- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    STGIFFDisplayLayerPatternizedCrossFadeEffect * combineEffec = STGIFFDisplayLayerPatternizedCrossFadeEffect.new;
    combineEffec.patternImageName = @"STGIFFDisplayLayerCrossFadeEffect_patt4.svg";

    UIImage * result = [combineEffec processImages:sourceImages];
    CGFloat diameter = CGSizeMinSide(result.size);

    return [result clipAsCircle:diameter*.86f scale:result.scale fillColor:UIColorFromRGB(0x352530)];
}


@end