//
// Created by BLACKGENE on 8/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <GPUImage/GPUImageTwoInputFilter.h>
#import "STGIFFDisplayLayerCrossFadeGradientMaskEffect.h"
#import "CALayer+STUtil.h"
#import "STGIFFDisplayLayerCrossFadeMaskEffect.h"
#import "NSObject+STUtil.h"
#import "NSString+STUtil.h"
#import "CCARadialGradientLayer.h"
#import "LEColorPicker.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageMonochromeFilter.h"
#import "GPUImageMonochromeFilter+STGPUImageFilter.h"
#import "GPUImageTransformFilter.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"
#import "STRasterizingImageSourceItem.h"
#import "STGIFFDisplayLayerEffectSharedUtil.h"


@implementation STGIFFDisplayLayerCrossFadeGradientMaskEffect

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyMatchUpColors = YES;
    }

    return self;
}


+ (UIImage *)crossFadingGradientMaskImageByStyle:(CrossFadeGradientMaskEffectStyle)style size:(CGSize)size locations:(NSArray<NSNumber *> *)locations{
    NSString * cacheKey = [@"STGIFFDisplayLayerCrossFadeGradientMaskEffect_gradient_"
            st_add:[[[@(style) stringValue]
                    st_add:NSStringFromCGSize(size)]
                    st_add:[locations componentsJoinedByString:@","]]];

    return [self st_cachedImage:cacheKey init:^UIImage * {

        switch(style){
            case CrossFadeGradientMaskEffectStyleLinearVertical:{
                CAGradientLayer * gradientLayer = [[CAGradientLayer alloc] init];
                gradientLayer.startPoint = CGPointMake(0.5,1.0);
                gradientLayer.endPoint = CGPointMake(0.5,0.0);
                gradientLayer.frame = (CGRect){CGPointZero, size};
                gradientLayer.colors = @[
                        (id)[[UIColor whiteColor] CGColor]
                        , (id)[[UIColor blackColor] CGColor]
                ];
                gradientLayer.locations = locations ?: @[@.35, @.75];
                return [gradientLayer UIImage:YES];
            }

            case CrossFadeGradientMaskEffectStyleLinearHorizontal:{
                CAGradientLayer * gradientLayer = [[CAGradientLayer alloc] init];
                gradientLayer.startPoint = CGPointMake(0.0,.5);
                gradientLayer.endPoint = CGPointMake(1.0,.5);
                gradientLayer.frame = (CGRect){CGPointZero, size};
                gradientLayer.colors = @[
                        (id)[[UIColor whiteColor] CGColor]
                        , (id)[[UIColor blackColor] CGColor]
                ];
                gradientLayer.locations = locations ?: @[@.35, @.75];
                return [gradientLayer UIImage:YES];
            }

            case CrossFadeGradientMaskEffectStyleRadial:{
                CCARadialGradientLayer * radialGradientLayer = [CCARadialGradientLayer layer];
                radialGradientLayer.frame = (CGRect){CGPointZero, size};
                CGFloat minSideSize = CGSizeMinSide(size);
                radialGradientLayer.gradientOrigin = CGPointMake(size.width/2, size.height/2);
                radialGradientLayer.gradientRadius = minSideSize/2;
                radialGradientLayer.colors = @[
                        (id)[[UIColor whiteColor] CGColor]
                        , (id)[[UIColor blackColor] CGColor]
                ];
                radialGradientLayer.locations = locations ?: @[@.6, @1];
                return [radialGradientLayer UIImage:YES];
            }
        }

        NSAssert(NO, @"Not supported gradient style.");
        return nil;
    }];
}

- (NSArray *)_composersToProcessCrossFaceEffect:(NSArray<UIImage *> *__nullable)sourceImages {
    UIImage * sourceImage = sourceImages[0];

    CGSize sourceImageSize = sourceImage.size;

    CrossFadeGradientMaskEffectStyle style = self.style;
    STGIFFDisplayLayerCrossFadeMaskEffect * crossFadeEffect = STGIFFDisplayLayerCrossFadeMaskEffect.new;

    UIImage * maskLayerImage = [self.class crossFadingGradientMaskImageByStyle:style size:sourceImageSize locations:self.locations];

    NSAssert(maskLayerImage, @"maskLayer is nil.");
    crossFadeEffect.maskImageSource = [STRasterizingImageSourceItem itemWithImage:maskLayerImage];
    return [crossFadeEffect composersToProcess:sourceImages];
}


- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    if(!self.style){
        self.style = CrossFadeGradientMaskEffectStyleLinearVertical;
    }
    NSArray * composers = [self _composersToProcessCrossFaceEffect:sourceImages];

    NSMutableArray * addingFilters = nil;

    if(self.automaticallyMatchUpColors){
        LEColorScheme * colorScheme1 = [self st_cachedObject:[sourceImages[1] st_uid] init:^id {
            return [[STGIFFDisplayLayerEffectSharedUtil colorPicker] colorSchemeFromImage:sourceImages[1]];
        }];
        addingFilters = [@[[GPUImageMonochromeFilter color:colorScheme1.backgroundColor intensity:.8]] mutableCopy];
    }

    for(STGPUImageOutputComposeItem * composeItem in composers){
        if(composeItem.composer && composeItem.source){
            composeItem.filters = [(composeItem.filters ?: @[]) arrayByAddingObjectsFromArray:addingFilters];
            break;
        }
    }

    return composers;
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    if(!self.style){
        self.style = CrossFadeGradientMaskEffectStyleLinearHorizontal;
    }
    NSArray * composers = [self _composersToProcessCrossFaceEffect:@[sourceImage]];
    for(STGPUImageOutputComposeItem * composeItem in composers){
        if(composeItem.source){
            composeItem.filters = [composeItem.filters ?: @[] arrayByAddingObject:
                    [GPUImageTransformFilter transform:CGAffineTransformMakeScale(-1,1)]
            ];
            break;
        }
    }
    return composers;
}
@end