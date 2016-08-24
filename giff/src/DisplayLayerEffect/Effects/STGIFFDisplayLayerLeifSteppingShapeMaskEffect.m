//
// Created by BLACKGENE on 7/20/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerLeifSteppingShapeMaskEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageTransformFilter.h"
#import "STGPUImageOutputComposeItem.h"
#import "NSNumber+STUtil.h"
#import "NSArray+STUtil.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"
#import "STRasterizingImageSourceItem.h"
#import "GPUImageNormalBlendFilter.h"
#import "NYXImagesKit.h"
#import "NSObject+STUtil.h"
#import "GPUImageAlphaBlendFilter.h"
#import "GPUImageAlphaBlendFilter+STGPUImageFilter.h"
#import "GPUImageDifferenceBlendFilter.h"
#import "GPUImageHardLightBlendFilter.h"
#import "GPUImageColorInvertFilter.h"


@implementation STGIFFDisplayLayerLeifSteppingShapeMaskEffect {
    //Standard method of multi blending : https://github.com/BradLarson/GPUImage/issues/269
    //http://leifpodhajsky.bigcartel.com/
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.minScaleOfShape = .2f;
        self.maxScaleOfShape = 1.2f;
        self.countOfShape = 4;

    }
    return self;
}

- (STRasterizingImageSourceItem *)primaryShapeSource {
    return _primaryShapeSource ?: [STRasterizingImageSourceItem itemWithBundleFileName:@"STGIFFDisplayLayerLeifSteppingShapeMaskEffect_default.svg"];
}

- (STRasterizingImageSourceItem *)secondaryShapeSource {
    return _secondaryShapeSource ?: [STRasterizingImageSourceItem itemWithBundleFileName:@"STGIFFDisplayLayerLeifSteppingShapeMaskEffect_default_rect.svg"];
}


- (NSArray *)_composersToProcessSingle:(UIImage *)sourceImage
                       shapeMaskSource:(STRasterizingImageSourceItem *)shapeMaskSource
                        allowInvertMix:(BOOL)allowInvertMix
               primaryBlendFilterClass:(Class)primaryComposerFilterClass
             secondaryBlendFilterClass:(Class)secondaryComposerFilterClass{
    NSUInteger count = self.countOfShape + 1;

    NSString * cacheKeyToGenMask = [NSString stringWithFormat:@"%@_%@_%@", NSStringFromClass(self.class), NSStringFromCGSize(sourceImage.size), shapeMaskSource.uuid];
    UIImage * clipedImageForShapeMask = [self st_cachedImage:cacheKeyToGenMask init:^UIImage * {
        return [sourceImage maskWithImage:[shapeMaskSource rasterize:sourceImage.size]];
    }];

    CGFloat minScale = self.minScaleOfShape;
    CGFloat maxScale = self.maxScaleOfShape;
    CGFloat maxDegree = self.maxDegreeForAllShapes;

    NSArray * composers = [[[@(count) st_intArray] reverse] mapWithIndex:^id(id object, NSInteger index) {
        @autoreleasepool {
            CGFloat offset = [object floatValue];

            STGPUImageOutputComposeItem *composeItem1 = STGPUImageOutputComposeItem.new;
            if (offset == count-1) { //background biggest image
                composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:NO];

            } else {
//            scaleValue *= AGKEaseOutWithOverShoot([object floatValue]/(count-1), 1.8f);
                composeItem1.source = [[GPUImagePicture alloc] initWithImage:clipedImageForShapeMask smoothlyScaleOutput:NO];

                //composer
                Class targetComposerFilterClassToApply = index % 2 && secondaryComposerFilterClass ? secondaryComposerFilterClass : primaryComposerFilterClass;
                composeItem1.composer = (GPUImageTwoInputFilter *)[[targetComposerFilterClassToApply alloc] init];

                //transform
                CGFloat scaleValue = AGKRemap(offset+1, 0, count-1, minScale, maxScale);
                GPUImageTransformFilter * transformFilter = [GPUImageTransformFilter scaleScalar:scaleValue];
                if(maxDegree){
                    [transformFilter rotate:AGKDegreesToRadians(AGKRemap(offset, 0, count - 1, 0, maxDegree))];
                }

                //append mix filters
                composeItem1.filters = allowInvertMix && index % 2 ?
                        @[[[GPUImageColorInvertFilter alloc] init],transformFilter] : @[transformFilter];
            }
            return composeItem1;
        }
    }];
    return composers;
}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    NSArray * composers0 = [self _composersToProcessSingle:sourceImages[0]
                                           shapeMaskSource:self.primaryShapeSource
                                            allowInvertMix:NO
                                   primaryBlendFilterClass:GPUImageNormalBlendFilter.class
                                 secondaryBlendFilterClass:nil];

    //GPUImageLightenBlendFilter
    //GPUImageSoftLightBlendFilter
    //GPUImageOverlayBlendFilter
    //GPUImageDifferenceBlendFilter
    //GPUImageDarkenBlendFilter
    //GPUImageHardLightBlendFilter
    NSArray * composers1 = [self _composersToProcessSingle:sourceImages[1]
                                           shapeMaskSource:self.secondaryShapeSource
                                            allowInvertMix:NO
                                   primaryBlendFilterClass:GPUImageHardLightBlendFilter.class
                                 secondaryBlendFilterClass:GPUImageDifferenceBlendFilter.class];

    STGPUImageOutputComposeItem * composers1_firstItem = [composers1 firstObject];
    composers1_firstItem.composer = [GPUImageAlphaBlendFilter alphaMix:0];

    NSMutableArray * resultComposers = [NSMutableArray array];
    for(id indexval in [@(composers0.count) st_intArray]){
        NSUInteger index = [indexval unsignedIntegerValue];
        STGPUImageOutputComposeItem * item0 = composers0[index];
        [resultComposers addObject:item0];

        STGPUImageOutputComposeItem * item1 = composers1[index];
        [resultComposers addObject:item1];
    }

    return resultComposers;

}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    return [self _composersToProcessSingle:sourceImage
                           shapeMaskSource:self.primaryShapeSource
                            allowInvertMix:YES
                   primaryBlendFilterClass:GPUImageNormalBlendFilter.class
                 secondaryBlendFilterClass:nil];

}

@end