//
// Created by BLACKGENE on 8/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerJulieCockburnEffect.h"
#import "CALayer+STUtil.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageMaskFilter.h"
#import "GPUImageTransformFilter.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"
#import "STRasterizingImageSourceItem.h"
#import "NSNumber+STUtil.h"
#import "GPUImageNormalBlendFilter.h"
#import "GPUImageLightenBlendFilter.h"
#import "GPUImageSoftLightBlendFilter.h"
#import "GPUImageAddBlendFilter.h"
#import "GPUImageMultiplyBlendFilter.h"
#import "GPUImageSourceOverBlendFilter.h"
#import "GPUImageScreenBlendFilter.h"
#import "GPUImageOpacityFilter.h"
#import "GPUImageOpacityFilter+STGPUImageFilter.h"


@implementation STGIFFDisplayLayerJulieCockburnEffect {

}

NSArray * BlendingFiltersClassNames;

- (instancetype)init {
    self = [super init];
    if (self) {
        //GPUImageNormalBlendFilter -> original
        //GPUImageSourceOverBlendFilter -> original
        //GPUImageSoftLightBlendFilter
        //GPUImageAddBlendFilter
        //GPUImageLightenBlendFilter
        //GPUImageMultiplyBlendFilter
        //GPUImageScreenBlendFilter

        //GPUImageDissolveBlendFilter -> normal but removed original pixels.

        //GPUImageDifferenceBlendFilter -> clipped but awesome.

        BlockOnce(^{
            (BlendingFiltersClassNames = @[
                    NSStringFromClass(GPUImageNormalBlendFilter.class),
                    NSStringFromClass(GPUImageSourceOverBlendFilter.class),
                    NSStringFromClass(GPUImageSoftLightBlendFilter.class),
                    NSStringFromClass(GPUImageAddBlendFilter.class),
                    NSStringFromClass(GPUImageLightenBlendFilter.class),
                    NSStringFromClass(GPUImageMultiplyBlendFilter.class),
                    NSStringFromClass(GPUImageScreenBlendFilter.class)
            ]);
        });
    }

    return self;
}


- (NSArray *)composersToProcess:(NSArray<UIImage *> *__nullable)sourceImages {
    UIImage * maskImage = nil;
    if(self.maskedImageSource){
        maskImage = [self.maskedImageSource rasterize:sourceImages[0].size];
    }else{
        CGSize size = [sourceImages[0] size];
        CAShapeLayer * layer = [CAShapeLayer layerWithSize:size];
        layer.fillColor = [UIColor whiteColor].CGColor;
        layer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(CGRectMakeWithSize_AGK(size), size.width*.35f, 0/*size.height*.05f*//*size.height*.3f*/)].CGPath;
        maskImage = [layer UIImage:YES];
    }

    NSMutableArray * composers = NSMutableArray.array;

    /*
     * get cliped image 0
     */
    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:maskImage composer:GPUImageMaskFilter.new] addFilters:@[
//            [GPUImageTransformFilter transform:CGAffineTransformMakeRotation(AGKDegreesToRadians(30))]
    ]]];
    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[0]] addFilters:@[
//            [GPUImageTransformFilter transform:CGAffineTransformMakeRotation(AGKDegreesToRadians(30))]
    ]]];
    UIImage * clipedImage = [self processComposers:[composers reverse]];
    [composers removeAllObjects];

    /*
     * get cliped image 1
     */
    UIImage * clipedImage1 = nil;
    if(sourceImages.count>1){
        [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:maskImage composer:GPUImageMaskFilter.new] addFilters:@[
        ]]];
        [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[1]] addFilters:@[
        ]]];
        clipedImage1 = [self processComposers:[composers reverse]];
        [composers removeAllObjects];
    }

    CGFloat gapOfDegree = 36;
    NSUInteger count = (NSUInteger) ((180+gapOfDegree) / gapOfDegree);
    for(id index in [@(count) st_intArray]){
        @autoreleasepool {
            NSUInteger i = [index unsignedIntegerValue];
            CGFloat degree = gapOfDegree * ([index floatValue]/*start degree is 'gapOfDegree'*/+1);
//            NSString * blenderClassName = [blendingFiltersClassNames st_objectOrNilAtIndex:[index unsignedIntegerValue]];
//            NSString * blenderClassName = NSStringFromClass(GPUImageMultiplyBlendFilter.class);
            NSString * blenderClassName = BlendingFiltersClassNames[0];

            GPUImageTwoInputFilter * blender = i==count-1 ?
                    GPUImageNormalBlendFilter.new : (GPUImageTwoInputFilter *)[NSClassFromString(blenderClassName ?: BlendingFiltersClassNames[0]) new];

            UIImage * targetImageToBlend = clipedImage1 ? (i % 2 ? clipedImage : clipedImage1) : clipedImage;

            [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:targetImageToBlend composer: blender] addFilters:@[
                    [[GPUImageTransformFilter transform:CGAffineTransformMakeRotation(AGKDegreesToRadians(degree))] scaleScalar:.9]
                    ,[GPUImageOpacityFilter opacity:.65]
            ]]];
        }
    }

    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage: sourceImages[0]] addFilters:@[
    ]]];

    return [composers reverse];
}

@end