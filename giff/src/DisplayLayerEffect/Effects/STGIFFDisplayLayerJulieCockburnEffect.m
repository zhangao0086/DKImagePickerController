//
// Created by BLACKGENE on 8/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerJulieCockburnEffect.h"
#import "CALayer+STUtil.h"
#import "CAShapeLayer+STUtil.h"
#import "STGPUImageOutputComposeItem.h"
#import "NYXImagesKit.h"
#import "UIImage+STUtil.h"
#import "GPUImageMaskFilter.h"
#import "GPUImageTransformFilter.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"
#import "NSNumber+STUtil.h"
#import "NSObject+BNRTimeBlock.h"
#import "GPUImageDarkenBlendFilter.h"
#import "GPUImageNormalBlendFilter.h"
#import "GPUImageLightenBlendFilter.h"
#import "GPUImageSoftLightBlendFilter.h"
#import "GPUImageDifferenceBlendFilter.h"
#import "GPUImageSubtractBlendFilter.h"
#import "GPUImageAddBlendFilter.h"
#import "GPUImageColorBlendFilter.h"
#import "GPUImageExclusionBlendFilter.h"
#import "GPUImageLuminosityBlendFilter.h"
#import "GPUImageMultiplyBlendFilter.h"
#import "GPUImageSourceOverBlendFilter.h"
#import "GPUImageLinearBurnBlendFilter.h"
#import "GPUImageColorDodgeBlendFilter.h"
#import "GPUImageScreenBlendFilter.h"
#import "GPUImageOverlayBlendFilter.h"
#import "GPUImageDissolveBlendFilter.h"
#import "NSArray+STUtil.h"


@implementation STGIFFDisplayLayerJulieCockburnEffect {
    NSArray * const BlendingFiltersClassNames;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        BlendingFiltersClassNames = @[
                NSStringFromClass(GPUImageNormalBlendFilter.class),
                NSStringFromClass(GPUImageSourceOverBlendFilter.class),
                NSStringFromClass(GPUImageSoftLightBlendFilter.class),
                NSStringFromClass(GPUImageAddBlendFilter.class),
                NSStringFromClass(GPUImageLightenBlendFilter.class),
                NSStringFromClass(GPUImageMultiplyBlendFilter.class),
                NSStringFromClass(GPUImageScreenBlendFilter.class)
        ];
    }

    return self;
}


- (NSArray *)composersToProcess:(NSArray<UIImage *> *__nullable)sourceImages {

    CGSize size = [sourceImages[0] size];
    CAShapeLayer * layer = [CAShapeLayer layerWithSize:size];
    layer.fillColor = [UIColor whiteColor].CGColor;

    layer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(CGRectMakeWithSize_AGK(size), 0, size.height*.3f)].CGPath;
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

    //GPUImageNormalBlendFilter -> original
    //GPUImageSourceOverBlendFilter -> original
    //GPUImageSoftLightBlendFilter
    //GPUImageAddBlendFilter
    //GPUImageLightenBlendFilter
    //GPUImageMultiplyBlendFilter
    //GPUImageScreenBlendFilter

    //GPUImageDissolveBlendFilter -> normal but removed original pixels.

    //GPUImageDifferenceBlendFilter -> clipped but awesome.
    
    NSUInteger count = (NSUInteger) ((180+gapOfDegree) / gapOfDegree);
    for(id index in [@(count) st_intArray]){
        @autoreleasepool {
            CGFloat degree = gapOfDegree * [index floatValue];
//            NSString * blenderClassName = [blendingFiltersClassNames st_objectOrNilAtIndex:[index unsignedIntegerValue]];
            NSString * blenderClassName = [BlendingFiltersClassNames st_objectOrNilAtIndex:randomir(1,BlendingFiltersClassNames.count-1)];
            GPUImageTwoInputFilter * blender = ([index unsignedIntegerValue]==count-1) ?
                    nil : (GPUImageTwoInputFilter *)[NSClassFromString(blenderClassName ?: BlendingFiltersClassNames[0]) new];

            [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:clipedImage composer: blender] addFilters:@[
                    [GPUImageTransformFilter transform:CGAffineTransformMakeRotation(AGKDegreesToRadians(degree))]
            ]]];
        }
    }

    return [composers reverse];
}

@end