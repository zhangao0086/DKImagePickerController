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

    CGSize size = [sourceImages[0] size];
    CAShapeLayer * layer = [CAShapeLayer layerWithSize:size];
    layer.fillColor = [UIColor whiteColor].CGColor;

    layer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(CGRectMakeWithSize_AGK(size), size.width*.35f, 0/*size.height*.05f*//*size.height*.3f*/)].CGPath;
    //TODO:추후 이걸 외부에셋으로 뺄 수도 있겠음
    UIImage * maskImage = [layer UIImage:YES];

    NSMutableArray * composers = NSMutableArray.array;

    //get cliped image
    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:maskImage composer:GPUImageMaskFilter.new] addFilters:@[
//            [GPUImageTransformFilter transform:CGAffineTransformMakeRotation(AGKDegreesToRadians(30))]
    ]]];
    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[0]] addFilters:@[
//            [GPUImageTransformFilter transform:CGAffineTransformMakeRotation(AGKDegreesToRadians(30))]
    ]]];
    UIImage * clipedImage = [self processComposers:[composers reverse]];

    [composers removeAllObjects];

    CGFloat gapOfDegree = 36;
    NSUInteger count = (NSUInteger) ((180+gapOfDegree) / gapOfDegree);
    for(id index in [@(count) st_intArray]){
        @autoreleasepool {
            CGFloat degree = gapOfDegree * ([index floatValue]/*start degree is 'gapOfDegree'*/+1);
//            NSString * blenderClassName = [blendingFiltersClassNames st_objectOrNilAtIndex:[index unsignedIntegerValue]];
//            NSString * blenderClassName = NSStringFromClass(GPUImageMultiplyBlendFilter.class);
            NSString * blenderClassName = BlendingFiltersClassNames[0];

            GPUImageTwoInputFilter * blender = [index unsignedIntegerValue]==count-1 ?
                    GPUImageNormalBlendFilter.new : (GPUImageTwoInputFilter *)[NSClassFromString(blenderClassName ?: BlendingFiltersClassNames[0]) new];

            [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:clipedImage composer: blender] addFilters:@[
                    [[GPUImageTransformFilter transform:CGAffineTransformMakeRotation(AGKDegreesToRadians(degree))] scaleScalar:.9]
                    ,[GPUImageOpacityFilter opacity:.8]
            ]]];
        }
    }

    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[0]] addFilters:@[
    ]]];

    return [composers reverse];
}

@end