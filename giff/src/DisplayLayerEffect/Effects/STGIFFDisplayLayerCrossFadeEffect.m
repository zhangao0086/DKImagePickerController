//
// Created by BLACKGENE on 8/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerCrossFadeEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "STFilter.h"
#import "STFilterManager.h"
#import "STGPUImageOutputComposeItem.h"
#import "SVGKImage.h"
#import "SVGKImage+STUtil.h"
#import "NSString+STUtil.h"
#import "UIImage+STUtil.h"


@implementation STGIFFDisplayLayerCrossFadeEffect {

}

- (UIImage *)patternImage:(CGSize)imageSize{

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
    [composers addObject:composeItemB];

    return [composers reverse];
}


- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    NSMutableArray * composers = [NSMutableArray array];

    //patt 1
    STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
    composeItem0.source = [[GPUImagePicture alloc] initWithImage:[self patternImage:sourceImage.size] smoothlyScaleOutput:NO];
    composeItem0.composer = GPUImageMaskFilter.new;
    composeItem0.filters = @[
            GPUImageColorInvertFilter.new
    ];
    [composers addObject:composeItem0];

    //image 1
    STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
    composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];
    composeItem1.filters = @[
    ];
    [composers addObject:composeItem1];

    return [composers reverse];
}

@end