//
// Created by BLACKGENE on 8/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerCrossFadeMaskEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "STFilter.h"
#import "STFilterManager.h"
#import "STGPUImageOutputComposeItem.h"
#import "SVGKImage.h"
#import "STRasterizingImageSourceItem.h"
#import "SVGKImage+STUtil.h"
#import "NSString+STUtil.h"
#import "UIImage+STUtil.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"
#import "NYXImagesKit.h"

//http://www.freepik.com/free-photos-vectors/stripes
//http://www.freepik.com/free-vector/different-patterns-with-golden-elements_865711.htm#term=stripes&page=1&position=24
//https://www.brusheezy.com/free/pattern-stripe
@implementation STGIFFDisplayLayerCrossFadeMaskEffect {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        _transformFadingImage = CGAffineTransformMakeScale(1.02f,1.02f);
    }

    return self;
}


- (UIImage *)patternImage:(CGSize)imageSize{

    UIImage * maskeImage = [self.maskImageSource rasterize:imageSize];
    return self.invertMaskImage ? [maskeImage invert] : maskeImage;
}

//TODO: 단순히 mask후 위에 draw를 하는 방식이므로 그냥 UIKit을 써서 하는게 더 빠르고 고품질일 듯. 테스트 후 비교 필요.
- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    NSMutableArray * composers = [NSMutableArray array];

    /*
     * masking image
     */
    UIImage * sourceImageForMask = [self patternImage:sourceImages[0].size];

    //patt
    STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
    composeItem0.source = [[GPUImagePicture alloc] initWithImage:sourceImageForMask smoothlyScaleOutput:NO];
    composeItem0.composer = GPUImageMaskFilter.new;
    composeItem0.category = STGPUImageOutputComposeItemCategoryMask;
    [composers addObject:composeItem0];

    //image
    STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
    composeItem1.category = STGPUImageOutputComposeItemCategorySourceImage;
    composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
    [composers addObject:composeItem1];

    UIImage * maskedImage = [[[STFilterManager sharedManager] buildTerminalOutputToComposeMultiSource:[composers reverse] forInput:nil] imageFromCurrentFramebuffer];

    /*
     * source[1] + masked
     */
    composers = [NSMutableArray array];

    STGPUImageOutputComposeItem * composeItemA = [STGPUImageOutputComposeItem new];
    composeItemA.source = [[GPUImagePicture alloc] initWithImage:maskedImage smoothlyScaleOutput:NO];
    composeItemA.composer = GPUImageNormalBlendFilter.new;
    composeItemA.category = STGPUImageOutputComposeItemCategoryMask;
    [composers addObject:composeItemA];

    STGPUImageOutputComposeItem * composeItemB = [STGPUImageOutputComposeItem new];
    composeItemB.category = STGPUImageOutputComposeItemCategorySourceImage;
    composeItemB.source = [[GPUImagePicture alloc] initWithImage:sourceImages[1] smoothlyScaleOutput:NO];
//    if(_scaleOfFadingImage!=1){
//        composeItemB.filters = @[
//                [GPUImageTransformFilter.new addScaleScalar:_scaleOfFadingImage]
//        ];
//    }
    [composers addObject:composeItemB];

    return [composers reverse];
}


- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
#if DEBUG
    if(!CGAffineTransformIsIdentity(_transformFadingImage)){
        oo(@"[!]WARNING: scaleOfFadingImage == 1 can't affect to apply this effect when process for single image");
    }
#endif

    NSMutableArray * composers = [NSMutableArray array];

    /*
     * masking image
     */
    UIImage * sourceImageForMask = [self patternImage:sourceImage.size];

    //patt
    STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
    composeItem0.source = [[GPUImagePicture alloc] initWithImage:sourceImageForMask smoothlyScaleOutput:NO];
    composeItem0.composer = GPUImageMaskFilter.new;
    [composers addObject:composeItem0];

    //image
    STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
    composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:NO];
    [composers addObject:composeItem1];

    UIImage * maskedImage = [[[STFilterManager sharedManager] buildTerminalOutputToComposeMultiSource:[composers reverse] forInput:nil] imageFromCurrentFramebuffer];

    /*
     * source[1] + masked
     */
    composers = [NSMutableArray array];

    STGPUImageOutputComposeItem * composeItemA = [STGPUImageOutputComposeItem new];
    composeItemA.source = [[GPUImagePicture alloc] initWithImage:maskedImage smoothlyScaleOutput:NO];
    composeItemA.composer = GPUImageNormalBlendFilter.new;
    [composers addObject:composeItemA];

    STGPUImageOutputComposeItem * composeItemB = [STGPUImageOutputComposeItem new];
    composeItemB.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:NO];
    if(!CGAffineTransformIsIdentity(_transformFadingImage)){
        composeItemB.filters = @[
                [GPUImageTransformFilter transform:_transformFadingImage]
        ];
    }

    [composers addObject:composeItemB];
    return [composers reverse];
}

@end