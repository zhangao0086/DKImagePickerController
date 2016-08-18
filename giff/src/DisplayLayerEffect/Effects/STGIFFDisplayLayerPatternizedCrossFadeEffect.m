//
// Created by BLACKGENE on 8/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerPatternizedCrossFadeEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "STFilter.h"
#import "STFilterManager.h"
#import "STGPUImageOutputComposeItem.h"
#import "SVGKImage.h"
#import "SVGKImage+STUtil.h"
#import "NSString+STUtil.h"
#import "UIImage+STUtil.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"

//http://www.freepik.com/free-photos-vectors/stripes
//http://www.freepik.com/free-vector/different-patterns-with-golden-elements_865711.htm#term=stripes&page=1&position=24
//https://www.brusheezy.com/free/pattern-stripe
@implementation STGIFFDisplayLayerPatternizedCrossFadeEffect {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        _transformFadingImage = CGAffineTransformMakeScale(1.02f,1.02f);
    }

    return self;
}


- (UIImage *)patternImage:(CGSize)imageSize{
    //리소소로 사용하는 이미지는 반드시 배경white과 전경black 모두 fill 되어 있어야 한다(투명 배경은 안됨)
    NSString * mimeTypeForPatternImage = [self.patternImageName mimeTypeFromPathExtension];
    if([@"image/svg+xml" isEqualToString:mimeTypeForPatternImage]){
        return [[SVGKImage imageNamedNoCache:self.patternImageName widthSizeWidth:imageSize.width] UIImage];
    }else if([@"image/png" isEqualToString:mimeTypeForPatternImage] || [@"image/jpeg" isEqualToString:mimeTypeForPatternImage]){
        return [UIImage imageBundled:self.patternImageName];
    }

    NSAssert(NO, ([mimeTypeForPatternImage st_add:@" is not supported file format"]));
    return nil;
}

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
    [composers addObject:composeItem0];

    //image
    STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
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
    [composers addObject:composeItemA];

    STGPUImageOutputComposeItem * composeItemB = [STGPUImageOutputComposeItem new];
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